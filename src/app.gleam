import env/action.{type Action}
import env/fight
import env/job
import env/world.{type LocationId}
import gleam/bool
import gleam/option.{None, Some}
import gleam/string
import lustre
import lustre/effect.{type Effect}
import msg.{type FightMove, type KeyboardEvent, type Msg, type SettingMsg}
import plinth/browser/document
import plinth/browser/event
import state/check
import state/init
import state/state.{type Player, type State, Player, State}
import util/localstore
import view/view

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let init = fn(_) { #(init(), setup_keyboard_listener()) }
  let app = lustre.application(init, update, view.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init() -> State {
  case localstore.try_load() {
    Some(last) -> {
      case last.settings.autoload {
        True -> last
        // copy over 'last' settings (otherwise autoload and autosave would get reseted)
        False -> State(..init.new_state(), settings: last.settings)
      }
    }
    None -> init.new_state()
    // _ -> new_state_fight()
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
    msg.KeyDown(key) -> handle_keyboard(state, key)
    msg.Noop -> state
    msg.SettingChange(msg) -> handle_setting_toggle(state, msg)
  }
  |> fn(state) {
    case msg != msg.Noop && state.settings.autosave {
      False -> state
      True -> localstore.try_save(state)
    }
  }
  |> no_eff
}

fn handle_move(state: State, location: LocationId) -> State {
  set_p(state, Player(..state.p, location:))
}

fn handle_keyboard(state: State, ev: KeyboardEvent) -> State {
  let location = world.get_location(state.p.location)
  let #(n, e, s, w) = location.connections

  case ev |> event.key |> string.lowercase {
    "w" if n != world.NoLocation -> handle_move(state, n)
    "d" if e != world.NoLocation -> handle_move(state, e)
    "s" if s != world.NoLocation -> handle_move(state, s)
    "a" if w != world.NoLocation -> handle_move(state, w)
    _ -> state
  }
}

fn handle_fight_move(state: State, move: FightMove) -> State {
  let next_state = fight.player_turn(state, move)

  // immediately do enemy-turn (if it's his turn)
  case next_state {
    State(_, option.Some(fight), _) if fight.phase == state.EnemyTurn ->
      fight.enemy_turn(state)
    s -> s
  }
}

fn handle_work(state: State) -> State {
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

  State(fight:, p:, settings: state.settings)
}

fn handle_action(state: State, action: Action) -> State {
  let assert [] = check.check_action_costs(state.p, action.costs)
    as "Illegal state - action should be disabled"
  action.apply_action(state, action)
}

fn handle_setting_toggle(state: State, msg: SettingMsg) -> State {
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

  State(..state, settings:)
}

// util ----------------------------------------
fn set_p(s: State, p: Player) -> State {
  State(..s, p:)
}

fn no_eff(a) -> #(a, Effect(b)) {
  #(a, effect.none())
}
