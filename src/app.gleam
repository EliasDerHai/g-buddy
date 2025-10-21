// IMPORTS ---------------------------------------------------------------------

import lustre
import lustre/effect.{type Effect}
import msg.{type Msg}
import state/state.{type State}
import view/view

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let init = fn(_) { #(state.init(), effect.none()) }
  let app = lustre.application(init, update, view.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// UPDATE ----------------------------------------------------------------------

fn update(model: State, msg: Msg) -> #(State, Effect(Msg)) {
  #(model, effect.none())
}
