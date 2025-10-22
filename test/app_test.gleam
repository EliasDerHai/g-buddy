import env/world
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

pub fn location_bidirectional_connections_test() {
  let apartment = world.get_location(world.Apartment)
  let bus_stop = world.get_location(world.BusStop)

  // Apartment connects north to BusStop
  let #(n, _e, _s, _w) = apartment.connections
  assert n == world.BusStop

  // BusStop should connect south back to Apartment
  let #(_n, _e, s, _w) = bus_stop.connections
  assert s == world.Apartment

  // BusStop connects east to Neighbor
  let #(_n, e, _s, _w) = bus_stop.connections
  assert e == world.Neighbor

  // Neighbor should connect west back to BusStop
  let neighbor = world.get_location(world.Neighbor)
  let #(_n, _e, _s, w) = neighbor.connections
  assert w == world.BusStop
}

pub fn add_limit_max_test() {
  let e = state.Energy(90, 100) |> state.add_energy(20)
  assert e.v == 100

  let h = state.Health(90, 100) |> state.add_health(20)
  assert h.v == 100
}
