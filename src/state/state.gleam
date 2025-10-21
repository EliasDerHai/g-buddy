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
  Health(v: Int)
}

pub type Player {
  Player(money: Money, health: Health, weapon: WeaponId, location: LocationId)
}

// INIT -------------------------------------------------
pub const start_money = 100

pub const start_health = 100

pub fn init() -> State {
  let p =
    Player(Money(start_money), Health(start_health), NoWeapon, world.Apartment)
  State(p)
}
