import gleam/float
import gleam/int
import gleam_community/maths

/// jitters a value +/- 30%
pub fn jitter(value: Int) {
  let value = value |> int.to_float
  let y = ran_tan()
  { value +. value *. y *. 0.3 } |> float.round
}

/// random value btw. -1 <-> 1 with high chance ~0 and lower chance of -1 or 1
fn ran_tan() {
  let x = float.random() *. 2.0 -. 1.0
  let assert Ok(x) = float.power(x, 3.0)
  maths.tan(x) |> float.clamp(-1.0, 1.0)
}
