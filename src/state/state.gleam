import env/world.{type LocationId}

pub type State {
  State(p: Player)
}

pub type Money {
  Money(v: Int)
}

pub type WeaponId {
  NoWeapon
  BrassKnuckles
}

pub type Health {
  Health(v: Int, max: Int)
}

pub type Energy {
  Energy(v: Int, max: Int)
}

pub type JobId {
  Lookout
  Slinger
}

pub type Player {
  Player(
    money: Money,
    health: Health,
    energy: Energy,
    weapon: WeaponId,
    location: LocationId,
    job: JobId,
  )
}

// INIT -------------------------------------------------
pub const start_money = 100

pub const start_health = 100

pub const max_health = 100

pub const start_energy = 100

pub const max_energy = 100

pub fn init() -> State {
  let p =
    Player(
      Money(start_money),
      Health(start_health, max_health),
      Energy(start_energy, max_energy),
      NoWeapon,
      world.Apartment,
      Lookout,
    )
  State(p)
}
