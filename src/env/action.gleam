import env/world.{type LocationId}
import gleam/list
import state/state.{type Player, type State, Player, State}

pub type ActionId {
  BusTo(LocationId)
  Workout
}

pub type Action {
  Action(
    id: ActionId,
    location: LocationId,
    costs: List(ActionActivationCost),
    special_effects: List(ActionSpecialEffect),
  )
}

pub type ActionActivationCost {
  Energy(cost: Int)
  Money(cost: Int)
}

pub type ActionSpecialEffect {
  BusToEffect(destination: LocationId)
  // TODO: add gym reward 
}

const all_actions = [
  Action(
    BusTo(world.CityCenter),
    world.BusStop,
    [Money(2)],
    [BusToEffect(world.CityCenter)],
  ),
  Action(
    BusTo(world.BusStop),
    world.CityCenter,
    [Money(2)],
    [BusToEffect(world.BusStop)],
  ),
  Action(Workout, world.Gym, [Energy(30)], []),
]

pub fn get_action_by_location(location: LocationId) -> List(Action) {
  all_actions |> list.filter(fn(el) { el.location == location })
}

pub fn apply_action(state: State, action: Action) -> State {
  let p =
    state.p
    |> apply_cost(action.costs)
    |> apply_specials(action.special_effects)

  State(..state, p:)
}

fn apply_specials(p: Player, requirements: List(ActionSpecialEffect)) -> Player {
  list.fold(requirements, p, fn(p, req) {
    case req {
      BusToEffect(destination:) -> Player(..p, location: destination)
    }
  })
}

fn apply_cost(p: Player, requirements: List(ActionActivationCost)) -> Player {
  list.fold(requirements, p, fn(p, req) {
    case req {
      Money(cost:) -> Player(..p, money: p.money |> state.add_money(-cost))
      Energy(cost:) -> Player(..p, energy: p.energy |> state.add_energy(-cost))
    }
  })
}
