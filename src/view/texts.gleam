import env/enemy
import env/world.{type LocationId}
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
