import env/action.{type Action}
import env/enemy.{Enemy}
import env/fight
import env/fight_types
import env/job
import env/shop.{type Buyable, type ConsumableId}
import env/story
import env/weapon
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
  type SettingMsg, type StoryMsg, type ToastMsg, type TooltipMsg,
}
import plinth/browser/document
import plinth/browser/event
import state/check
import state/init
import state/state.{
  type Fight, type GameState, type Player, type State, EnemyTurn, Fight,
  GameState, Inventory, Player, PlayerWon, State,
}
import state/toast
import util/either.{Left, Right}
import util/localstore
import util/time
import view/texts
import view/view

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let init = fn(_) {
    #(
      init(),
      effect.batch([
        setup_keyboard_listener(),
        disp(msg.PlayerMove(world.Apartment)),
      ]),
    )
  }
  let app = lustre.application(init, update, view.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init() -> State {
  //let new_state = init.new_state_fight()
  let new_state = init.new_state()

  let settings =
    localstore.try_load_settings()
    |> option.unwrap(new_state.settings)

  let #(p, overlay) = case settings.autoload {
    False -> #(new_state.p, new_state.overlay)
    True -> {
      case localstore.try_load_game_state() {
        Some(GameState(p:, fight:)) -> #(p, case fight {
          None -> new_state.overlay
          Some(f) -> state.OverlayFight(f)
        })
        None -> #(new_state.p, new_state.overlay)
      }
    }
  }

  State(p:, overlay:, settings:, toasts: [], active_tooltip: None)
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
    msg.PlayerConsum(item) -> handle_consumption(state, item)
    msg.PlayerStory(msg) -> handle_story_msg(state, msg)
    msg.KeyDown(key) -> handle_keyboard(state, key)
    msg.Noop -> state |> no_eff
    msg.SettingChange(msg) -> handle_setting_toggle(state, msg)
    msg.ToastChange(msg) -> handle_toast(state, msg)
    msg.TooltipChange(msg) -> handle_tooltip(state, msg)
    // TODO: remove other msgs and use OpenOverlay instead of various others
    msg.OpenOverlay(overlay) -> State(..state, overlay:) |> no_eff
    msg.CloseOverlay -> State(..state, overlay: state.NoOverlay) |> no_eff
  }
  |> pair.map_first(try_save_to_localstore(msg, _))
}

fn handle_keyboard(state: State, ev: KeyboardEvent) -> #(State, Effect(Msg)) {
  let overlay_open = state.overlay != state.NoOverlay
  use <- bool.guard(overlay_open, state |> no_eff)

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

fn handle_move(state: State, location: LocationId) -> #(State, Effect(Msg)) {
  let p = Player(..state.p, location:)

  let story_activation =
    p.story
    |> dict.values
    |> list.find(fn(chapter_id) {
      let chap = chapter_id |> story.story_chapter
      case chap.activation {
        story.Active(_, _) -> False
        story.Auto(location) -> p.location == location && chap.condition(p)
      }
    })
    |> option.from_result

  case story_activation {
    Some(chap) ->
      State(..state, p:) |> any_eff(msg.PlayerStory(msg.StoryActivate(chap)))

    None -> {
      let GameState(p:, fight:) =
        location
        |> enemy.random_location_trouble
        |> option.map(fn(e_id) { fight.start_fight(e_id, p) })
        |> option.unwrap(GameState(p, state |> state.get_fight))

      let state = State(..state, p:)

      case fight {
        None -> state |> no_eff
        Some(_) -> state |> toast_eff("Random streetfight occurred!")
      }
    }
  }
}

fn handle_fight_move(state: State, move: FightMove) -> #(State, Effect(a)) {
  let assert Some(fight) = state |> state.get_fight
    as "Illegal state - fight move outside of fight"

  let GameState(p:, fight:) = player_turn(state.p, fight, move)

  // immediately do enemy-turn (if it's his turn)
  let GameState(p:, fight:) = case fight {
    option.Some(f) if f.phase == state.EnemyTurn -> fight.enemy_turn(state.p, f)
    _ -> GameState(p:, fight:)
  }

  State(..state, p:) |> state.set_fight(fight) |> no_eff
}

fn player_turn(p: Player, fight: Fight, move: FightMove) -> GameState {
  case move {
    msg.FightAttack(move) -> {
      let assert state.PlayerTurn = fight.phase
        as "Illegal state - cannot attack, not player's turn"
      let assert True = move.stamina_cost <= fight.stamina.v
        as "Illegal state - not enough stamina"

      let weapon.WeaponStat(id: _, dmg:, def: _, crit:) =
        p.equipped_weapon |> weapon.weapon_stats
      let #(skill_dmg, _, crit_def) = state.skill_dmg_def(p.skills)

      // TODO: UI for this
      let dmg = dmg |> fight_types.add_dmg(skill_dmg)
      let crit = crit |> fight_types.add_crit(crit_def)

      let real_dmg = fight.dmg_calc(dmg, crit, fight.enemy.def)
      let health = fight.enemy.health - real_dmg
      let stamina = fight.stamina |> state.add_stamina(-move.stamina_cost)

      let enemy = Enemy(..fight.enemy, health:)
      let next_phase = case enemy.health > 0 {
        True -> EnemyTurn
        False -> PlayerWon(reward: enemy.get_victory_reward(enemy))
      }

      let fight =
        Some(
          Fight(
            ..fight,
            phase: next_phase,
            enemy:,
            stamina:,
            last_player_dmg: Some(real_dmg),
            last_enemy_dmg: case next_phase {
              PlayerWon(_) -> None
              _ -> fight.last_enemy_dmg
            },
          ),
        )

      GameState(p:, fight:)
    }
    msg.FightRegenStamina ->
      GameState(
        p:,
        fight: Some(
          Fight(
            ..fight,
            phase: EnemyTurn,
            stamina: fight.stamina |> state.refill_stamina,
            last_player_dmg: None,
          ),
        ),
      )
    msg.FightFlee ->
      GameState(
        p:,
        fight: Some(
          Fight(
            ..fight,
            phase: EnemyTurn,
            flee_pending: True,
            last_player_dmg: None,
          ),
        ),
      )
    msg.FightEnd -> {
      let assert True = fight.phase |> fight.is_finite_phase as "Illegal state"

      let p = case fight.phase {
        PlayerWon(reward:) ->
          Player(..p, money: p.money |> state.add_money(reward))
        _ -> p
      }

      GameState(p:, fight: None)
    }
  }
}

fn handle_work(state: State) -> #(State, Effect(Msg)) {
  let p = state.p
  let job_stats = p.job |> job.job_stats
  let energy =
    p.energy
    |> state.add_energy(-job_stats.energy_cost)
  let money = p.money |> state.add_money(job_stats.base_income)
  let p = Player(..p, energy:, money:)

  case
    {
      p.job
      |> job.job_stats
    }.trouble
    |> job.roll_trouble_dice
    |> option.map(fn(e_id) { fight.start_fight(e_id, p) })
  {
    None -> State(..state, p:) |> no_eff
    Some(GameState(p:, fight:)) ->
      State(..state, p:)
      |> state.set_fight(fight)
      |> toast_eff("Random job brawl occurred")
  }
}

fn handle_action(state: State, action: Action) -> #(State, Effect(a)) {
  let assert [] = check.check_action_costs(state.p, action.costs)
    as "Illegal state - action should be disabled"
  action.apply_action(state, action) |> no_eff
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
    msg.ShopClose -> State(..state, overlay: state.NoOverlay)
    msg.ShopOpen(options:) ->
      State(..state, overlay: state.OverlayShop(options))
  }
  |> no_eff
}

fn handle_consumption(state: State, id: ConsumableId) -> #(State, Effect(Msg)) {
  let consumables =
    state.p.inventory.consumables
    |> dict.upsert(id, fn(curr) {
      case curr {
        None | Some(0) ->
          panic as { "not enough " <> id |> string.inspect <> " to consume" }
        Some(other) -> other - 1
      }
    })
    |> dict.filter(fn(_, amount) { amount > 0 })
  let effects = id |> shop.consumable_effect

  let p =
    effects
    |> list.fold(state.p, fn(p, eff) {
      case eff {
        shop.ConsumableEffectEnergy(gain:) ->
          Player(
            ..p,
            inventory: Inventory(..state.p.inventory, consumables:),
            energy: p.energy |> state.add_energy(gain),
          )
        shop.ConsumableEffectHealth(gain:) ->
          Player(
            ..p,
            inventory: Inventory(..state.p.inventory, consumables:),
            health: p.health |> state.add_health(gain),
          )
      }
    })

  State(..state, p:) |> toast_eff("Consumed " <> id |> texts.consumable)
}

fn handle_story_msg(state: State, msg: StoryMsg) -> #(State, Effect(Msg)) {
  case msg {
    msg.StoryActivate(chap:) ->
      State(..state, overlay: state.OverlayStory(chap, 0)) |> no_eff
    msg.StoryOptionPick(chap:, node_id:) ->
      State(..state, overlay: state.OverlayStory(chap, node_id)) |> no_eff
    msg.StoryChapterComplete(chap) -> {
      let chap = chap |> story.story_chapter
      let p =
        Player(
          ..state.p,
          story: state.p.story |> dict.insert(chap.line_id, chap.next_chapter),
        )
        |> chap.effect

      let state = State(..state, p:, overlay: state.NoOverlay)

      case chap.effect_toast_msg {
        None -> state |> no_eff
        Some(m) -> state |> toast_eff(m)
      }
    }
  }
}

fn handle_setting_toggle(state: State, msg: SettingMsg) -> #(State, Effect(Msg)) {
  let state.Settings(autosave:, autoload:) = state.settings

  let settings = case msg {
    msg.SettingReset -> {
      let _ = localstore.reset()
      state.settings
    }
    msg.SettingToggleAutoload ->
      state.Settings(..state.settings, autoload: autoload |> bool.negate)
    msg.SettingToggleAutosave ->
      state.Settings(..state.settings, autosave: autosave |> bool.negate)
    msg.SettingToggleDisplay -> state.settings
  }

  case msg {
    msg.SettingReset -> #(
      State(..init(), settings:),
      effect.batch([
        msg.ToastChange(msg.ToastAdd(toast.create_info_toast("Storage reset")))
          |> disp,
        msg.PlayerMove(world.Apartment)
          |> disp,
      ]),
    )
    msg.SettingToggleDisplay ->
      State(..state, overlay: case state.overlay == state.OverlaySaveLoad {
        False -> state.OverlaySaveLoad
        True -> state.NoOverlay
      })
      |> no_eff
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

fn handle_tooltip(state: State, msg: TooltipMsg) -> #(State, Effect(Msg)) {
  case msg {
    msg.TooltipShow(id) -> State(..state, active_tooltip: Some(id)) |> no_eff
    msg.TooltipHide -> State(..state, active_tooltip: None) |> no_eff
  }
}

fn try_save_to_localstore(msg: Msg, state: State) -> State {
  case msg {
    msg.SettingChange(m) if m != msg.SettingReset ->
      localstore.try_save_settings(state.settings)
    msg.PlayerAction(_)
      | msg.PlayerWork
      | msg.PlayerMove(_)
      | msg.PlayerFightMove(_)
      | msg.PlayerShop(_)
      | msg.PlayerConsum(_)
      if state.settings.autosave
    -> localstore.try_save_game_state(state.p, state |> state.get_fight)
    _ -> Nil
  }
  state
}

// util ----------------------------------------

fn no_eff(a) -> #(a, Effect(b)) {
  #(a, effect.none())
}

fn toast_eff(a, info_msg: String) -> #(a, Effect(Msg)) {
  #(
    a,
    effect.from(fn(dispatch) {
      msg.ToastChange(msg.ToastAdd(toast.create_info_toast(info_msg)))
      |> dispatch
      Nil
    }),
  )
}

fn any_eff(a, msg: Msg) -> #(a, Effect(Msg)) {
  #(a, disp(msg))
}

fn disp(msg: Msg) -> Effect(Msg) {
  effect.from(fn(dispatch) {
    msg |> dispatch
    Nil
  })
}
