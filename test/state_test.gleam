import app
import gleam/json
import gleeunit
import gleeunit/should
import state/state_decoder
import state/state_encoder

pub fn main() {
  gleeunit.main()
}

pub fn state_roundtrip_test() {
  let state = app.new_player()

  let actual =
    state
    |> state_encoder.state_to_json
    |> json.to_string
    |> json.parse(state_decoder.state_decoder())
    |> should.be_ok

  actual |> should.equal(state)
}
