// IMPORTS ---------------------------------------------------------------------

import env/action.{type Action}
import env/fight
import env/job
import gleam/option.{Some}
import lustre
import lustre/effect.{type Effect}
import msg.{type FightMove, type Msg}
import state/check
import state/state.{type Player, type State, Player, State}
import view/view

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let init = fn(_) { #(state.init(), effect.none()) }
  let app = lustre.application(init, update, view.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// UPDATE ----------------------------------------------------------------------

fn update(state: State, msg: Msg) -> #(State, Effect(Msg)) {
  let p = state.p
  case msg {
    msg.PlayerMove(location) -> set_p(state, Player(..p, location:)) |> no_eff
    msg.PlayerWork -> handle_work(p) |> no_eff
    msg.PlayerFightMove(move) -> handle_fight_move(state, move)
    msg.PlayerAction(action) -> handle_action(state, action) |> no_eff
  }
}

fn handle_fight_move(state: State, move: FightMove) -> #(State, Effect(Msg)) {
  let assert Some(fight) = state.fight
    as "Illegal state - fight move outside of fight"
  let next_state = fight.player_turn(state.p, fight, move)

  // immediately do enemy-turn (if it's his turn)
  case next_state {
    State(p, option.Some(fight)) if fight.phase == state.EnemyTurn ->
      fight.enemy_turn(p, fight)
    s -> s
  }
  |> no_eff
}

fn handle_work(p: Player) -> State {
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

  State(fight:, p:)
}

fn handle_action(state: State, action: Action) -> State {
  let assert [] = check.check_action_costs(state.p, action.costs)
    as "Illegal state - action should be disabled"
  action.apply_action(state, action)
}

// util ----------------------------------------
fn set_p(s: State, p: Player) -> State {
  State(..s, p:)
}

fn no_eff(a) -> #(a, Effect(b)) {
  #(a, effect.none())
}
