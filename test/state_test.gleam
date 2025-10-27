import gleam/json
import gleeunit
import gleeunit/should
import state/init
import state/state
import state/state_decoder
import state/state_encoder

pub fn main() {
  gleeunit.main()
}

pub fn state_roundtrip_no_fight_test() {
  init.new_state() |> roundtrip
}

pub fn state_roundtrip_with_fight_test() {
  init.new_state_fight() |> roundtrip
}

fn roundtrip(state: state.State) {
  let state = state.GameState(state.p, state.fight)
  let actual =
    state
    |> state_encoder.game_state_to_json
    |> json.to_string
    |> json.parse(state_decoder.game_state_decoder())
    |> should.be_ok

  actual |> should.equal(state)
}
