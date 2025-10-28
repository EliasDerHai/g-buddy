import env/action.{type ActionId}
import env/attack.{type AttackId}
import env/enemy.{type EnemyId}
import env/shop.{type ConsumableId}
import env/weapon.{type WeaponId}
import env/world.{type LocationId}
import gleam/int
import state/check.{type DeniedReason}
import state/state.{type JobId}

pub fn location(id: LocationId) -> String {
  case id {
    world.NoLocation -> "-"
    world.Apartment -> "Apartment"
    world.BusStop -> "Bus-Stop"
    world.Neighbor -> "Neighbor"
    world.SlingerCorner -> "Slinger Corner"
    world.CityCenter -> "City Center"
    world.Gym -> "Gym"
    world.Arms -> "Arms & Ammu"
    world.GasStation -> "Gas station"
  }
}

pub fn weapon(id: WeaponId) -> String {
  case id {
    weapon.NoWeapon -> "Fists"
    weapon.BrassKnuckles -> "Brass Knuckles"
  }
}

pub fn job(id: JobId) -> String {
  case id {
    state.Lookout -> "Lookout"
    state.Slinger -> "Slinger"
  }
}

pub fn enemy(id: EnemyId) -> String {
  case id {
    enemy.Lvl1 -> "Drunkard"
    enemy.Lvl2 -> "Goon"
  }
}

pub fn action(id: ActionId) {
  case id {
    action.BusTo(dest) ->
      "Bus to "
      <> dest
      |> location
    action.WorkoutStrength -> "Workout (str)"
    action.WorkoutDexterity -> "Workout (dex)"
    action.Sleep -> "End day"
  }
}

pub fn disabled_reason(id: DeniedReason) -> String {
  case id {
    check.Insufficient(action.Energy(cost:)) ->
      "Not enough energy (requires ⚡️" <> cost |> int.to_string <> ")"
    check.Insufficient(action.Money(cost:)) ->
      "Not enough money (price $" <> cost |> int.to_string <> ")"
  }
}

pub fn attack(id: AttackId) -> String {
  case id {
    attack.NormalBlow -> "Normal Blow"
    attack.PowerSlam -> "Power Slam"
    attack.KarateKick -> "Karate Kick"
  }
}

pub fn consumable(id: ConsumableId) -> String {
  case id {
    shop.EnergyDrink -> "Energy Drink"
    shop.SmallHealthPack -> "Small Health Pack"
    shop.BigHealthPack -> "Big Health Pack"
  }
}
