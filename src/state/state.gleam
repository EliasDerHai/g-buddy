import env/enemy.{type EnemyId}
import env/world.{type LocationId}
import gleam/int
import gleam/option.{type Option}

pub type State {
  State(p: Player, fight: Option(Fight))
}

pub type Fight {
  Fight(enemy: EnemyId, round: Int)
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
  State(p, option.None)
}

fn min_max(v: Int, min: Int, max: Int) {
  v
  |> int.min(max)
  |> int.max(min)
}

pub fn add_energy(current: Energy, v: Int) {
  Energy(current.v + v |> min_max(0, current.max), current.max)
}

pub fn add_health(current: Health, v: Int) {
  Health(current.v + v |> min_max(0, current.max), current.max)
}

pub fn add_money(current: Money, v: Int) -> Money {
  Money(current.v + v)
}
