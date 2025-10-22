// IMPORTS ---------------------------------------------------------------------

import env/job
import gleam/option
import lustre
import lustre/effect.{type Effect}
import msg.{type Msg}
import state/state.{type Player, type State, Fight, Player, State}
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
  }
}

fn handle_work(p: Player) -> State {
  let energy =
    p.energy
    |> state.add_energy(-{ p.job |> job.job_stats }.energy_cost)

  let p = Player(..p, energy: energy)
  let fight =
    {
      p.job
      |> job.job_stats
    }.trouble
    |> job.roll_trouble_dice
    |> option.map(fn(enemy) { Fight(enemy, 0) })

  State(fight:, p:)
}

// util ----------------------------------------
fn set_p(s: State, p: Player) -> State {
  State(..s, p:)
}

fn no_eff(a) -> #(a, Effect(b)) {
  #(a, effect.none())
}
