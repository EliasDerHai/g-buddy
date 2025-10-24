import env/action
import env/enemy
import env/world.{type LocationId}
import gleam/int
import state/check
import state/state

pub fn location(id: LocationId) -> String {
  case id {
    world.NoLocation -> "-"
    world.Apartment -> "Apartment"
    world.BusStop -> "Bus-Stop"
    world.Neighbor -> "Neighbor"
    world.SlingerCorner -> "Slinger Corner"
    world.CityCenter -> "City Center"
    world.Gym -> "Gym"
  }
}

pub fn weapon(id: state.WeaponId) -> String {
  case id {
    state.NoWeapon -> "Fists"
    state.BrassKnuckles -> "Brass Knuckles"
  }
}

pub fn job(id: state.JobId) -> String {
  case id {
    state.Lookout -> "Lookout"
    state.Slinger -> "Slinger"
  }
}

pub fn enemy(id: enemy.EnemyId) -> String {
  case id {
    enemy.Lvl1 -> "Drunkard"
    enemy.Lvl2 -> "Goon"
  }
}

pub fn action(id: action.ActionId) {
  case id {
    action.BusTo(dest) ->
      "Bus to "
      <> dest
      |> location
    action.Workout -> "Workout"
    action.Sleep -> "End day"
  }
}

pub fn disabled_reason(id: check.DeniedReason) -> String {
  case id {
    check.Insufficient(action.Energy(cost:)) ->
      "Not enough energy (requires " <> cost |> int.to_string <> ")"
    check.Insufficient(action.Money(cost:)) ->
      "Not enough money (price $" <> cost |> int.to_string <> ")"
  }
}
