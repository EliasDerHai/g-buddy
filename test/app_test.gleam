import gleeunit
import state/state

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn init_test() {
  let s = state.init()

  assert s.p.health.v == state.start_health
  assert s.p.money.v == state.start_money
}
