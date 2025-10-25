import gleam/json
import gleeunit
import gleeunit/should
import state/init
import state/state_decoder
import state/state_encoder

pub fn main() {
  gleeunit.main()
}

pub fn state_roundtrip_no_fight_test() {
  init.new_player() |> roundtrip
}

pub fn state_roundtrip_with_fight_test() {
  init.new_player_fight() |> roundtrip
}

fn roundtrip(state) {
  let actual =
    state
    |> state_encoder.state_to_json
    |> json.to_string
    |> json.parse(state_decoder.state_decoder())
    |> should.be_ok

  actual |> should.equal(state)
}
