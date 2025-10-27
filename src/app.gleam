import env/action.{type Action}
import env/fight
import env/job
import env/shop.{type Buyable}
import env/world.{type LocationId}
import gleam/bool
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/set
import gleam/string
import lustre
import lustre/effect.{type Effect}
import msg.{
  type FightMove, type KeyboardEvent, type Msg, type PlayerShopMsg,
  type SettingMsg, type ToastMsg,
}
import plinth/browser/document
import plinth/browser/event
import state/check
import state/init
import state/state.{type Player, type State, Inventory, Player, State}
import state/toast
import util/either.{Left, Right}
import util/localstore
import util/time
import view/view

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let init = fn(_) { #(init(), setup_keyboard_listener()) }
  let app = lustre.application(init, update, view.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init() -> State {
  let new_state = init.new_state_fight()
  // let new_state = init.new_state()

  case localstore.try_load() {
    Some(last) -> {
      case last.settings.autoload {
        True -> last
        // copy over 'last' settings (otherwise autoload and autosave would get reseted)
        False -> State(..new_state, settings: last.settings)
      }
    }
    None -> new_state
  }
}

fn setup_keyboard_listener() -> Effect(Msg) {
  effect.from(fn(dispatch) {
    document.add_event_listener("keydown", fn(raw_event) {
      dispatch(msg.KeyDown(raw_event))
    })
  })
}

// UPDATE ----------------------------------------------------------------------

fn update(state: State, msg: Msg) -> #(State, Effect(Msg)) {
  case msg {
    msg.PlayerMove(location) -> handle_move(state, location)
    msg.PlayerWork -> handle_work(state)
    msg.PlayerFightMove(move) -> handle_fight_move(state, move)
    msg.PlayerAction(action) -> handle_action(state, action)
    msg.PlayerShop(shop) -> handle_shop(state, shop)
    msg.KeyDown(key) -> handle_keyboard(state, key)
    msg.Noop -> state |> no_eff
    msg.SettingChange(msg) -> handle_setting_toggle(state, msg)
    msg.ToastChange(msg) -> handle_toast(state, msg)
    msg.TooltipChange(msg) -> handle_tooltip(state, msg)
  }
  |> pair.map_first(try_save_state_to_localstore(msg, _))
}

fn handle_shop(state: State, shop: PlayerShopMsg) -> #(State, Effect(Msg)) {
  let buy = fn(state: State, item: Buyable) -> State {
    let p = state.p
    let assert True = p.money.v >= item.price
    let money = p.money |> state.add_money(-item.price)

    let inventory = case item.id {
      Right(consumable_id) ->
        Inventory(
          ..p.inventory,
          consumables: p.inventory.consumables
            |> dict.upsert(consumable_id, fn(amount) {
              { amount |> option.unwrap(0) } + 1
            }),
        )
      Left(weapon_id) ->
        Inventory(
          ..p.inventory,
          collected_weapons: p.inventory.collected_weapons
            |> set.insert(weapon_id),
        )
    }

    State(..state, p: Player(..p, money:, inventory:))
  }

  case shop {
    msg.ShopBuy(item:) -> state |> buy(item)
    msg.ShopClose -> State(..state, buyables: [])
    msg.ShopOpen(options:) -> State(..state, buyables: options)
  }
  |> no_eff
}

fn handle_move(state: State, location: LocationId) -> #(State, Effect(a)) {
  set_p(state, Player(..state.p, location:))
  |> no_eff
}

fn handle_keyboard(state: State, ev: KeyboardEvent) -> #(State, Effect(a)) {
  let location = world.get_location(state.p.location)
  let #(n, e, s, w) = location.connections

  case ev |> event.key |> string.lowercase {
    "w" if n != world.NoLocation -> handle_move(state, n)
    "d" if e != world.NoLocation -> handle_move(state, e)
    "s" if s != world.NoLocation -> handle_move(state, s)
    "a" if w != world.NoLocation -> handle_move(state, w)
    _ -> state |> no_eff
  }
}

fn handle_fight_move(state: State, move: FightMove) -> #(State, Effect(a)) {
  let state = fight.player_turn(state, move)

  // immediately do enemy-turn (if it's his turn)
  case state.fight {
    option.Some(fight) if fight.phase == state.EnemyTurn ->
      fight.enemy_turn(state)
    _ -> state
  }
  |> no_eff
}

fn handle_work(state: State) -> #(State, Effect(a)) {
  let p = state.p
  let job_stats = p.job |> job.job_stats
  let energy =
    p.energy
    |> state.add_energy(-job_stats.energy_cost)
  let money = p.money |> state.add_money(job_stats.base_income)
  let p = Player(..p, energy:, money:)
  let fight =
    {
      p.job
      |> job.job_stats
    }.trouble
    |> job.roll_trouble_dice
    |> option.map(fn(e_id) { fight.start_fight(e_id, p) })

  State(..state, fight:, p:) |> no_eff
}

fn handle_action(state: State, action: Action) -> #(State, Effect(a)) {
  let assert [] = check.check_action_costs(state.p, action.costs)
    as "Illegal state - action should be disabled"
  action.apply_action(state, action) |> no_eff
}

fn handle_setting_toggle(state: State, msg: SettingMsg) -> #(State, Effect(Msg)) {
  let state.Settings(display:, autosave:, autoload:) = state.settings

  let settings = case msg {
    msg.SettingReset -> {
      let _ = localstore.reset()
      state.settings
    }
    msg.SettingToggleAutoload ->
      state.Settings(..state.settings, autoload: autoload |> bool.negate)
    msg.SettingToggleAutosave ->
      state.Settings(..state.settings, autosave: autosave |> bool.negate)
    msg.SettingToggleDisplay ->
      state.Settings(..state.settings, display: case display {
        state.Hidden -> state.SaveLoad
        state.SaveLoad -> state.Hidden
      })
  }

  case msg {
    msg.SettingReset -> #(
      State(..state, settings:),
      effect.from(fn(dispatch) {
        msg.ToastChange(msg.ToastAdd(toast.create_info_toast("Storage reset")))
        |> dispatch
        Nil
      }),
    )
    _ -> State(..state, settings:) |> no_eff
  }
}

fn handle_toast(state: State, msg: ToastMsg) -> #(State, Effect(Msg)) {
  case msg {
    msg.ToastAdd(t) -> {
      let timeout_effect =
        effect.from(fn(dispatch) {
          time.set_timeout(
            fn() { dispatch(msg.ToastChange(msg.ToastRemove(t.id))) },
            t.duration,
          )
          Nil
        })

      #(State(..state, toasts: [t, ..state.toasts]), timeout_effect)
    }
    msg.ToastRemove(id:) ->
      State(
        ..state,
        toasts: state.toasts |> list.filter(fn(el) { el.id != id }),
      )
      |> no_eff
  }
}

fn handle_tooltip(state: State, msg: msg.TooltipMsg) -> #(State, Effect(Msg)) {
  case msg {
    msg.TooltipShow(id) -> State(..state, active_tooltip: Some(id)) |> no_eff
    msg.TooltipHide -> State(..state, active_tooltip: None) |> no_eff
  }
}

fn try_save_state_to_localstore(msg: Msg, state: State) {
  case msg {
    msg.PlayerAction(_)
      | msg.PlayerWork
      | msg.PlayerMove(_)
      | msg.PlayerFightMove(_)
      if state.settings.autosave
    -> localstore.try_save(state)
    // FIXME: storing autoload/autosave with state is inevitably a bit broken - options:
    // - split into different fields on localstore (clean)
    // - check current persistent state (patch settings, fallback init_state) (bit hacky)
    msg.SettingChange(_) -> localstore.try_save(state)
    _ -> state
  }
}

// util ----------------------------------------
fn set_p(s: State, p: Player) -> State {
  State(..s, p:)
}

fn no_eff(a) -> #(a, Effect(b)) {
  #(a, effect.none())
}
