// IMPORTS ---------------------------------------------------------------------

import env/fight
import env/job
import gleam/option
import lustre
import lustre/effect.{type Effect}
import msg.{type Msg}
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
  echo msg
  case msg {
    msg.PlayerMove(location) -> set_p(state, Player(..p, location:)) |> no_eff
    msg.PlayerWork -> handle_work(p) |> no_eff
    // TODO: put together the pieces of the fight mechanic 
    msg.PlayerFightMove(_) -> todo
  }
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

// util ----------------------------------------
fn set_p(s: State, p: Player) -> State {
  State(..s, p:)
}

fn no_eff(a) -> #(a, Effect(b)) {
  #(a, effect.none())
}
