import env/enemy.{type Enemy}
import env/world.{type LocationId}
import gleam/int
import gleam/option.{type Option}

pub type State {
  State(p: Player, fight: Option(Fight), settings: Settings)
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

pub type SkillId {
  Strength
  Dexterity
  Intelligence
  Charm
}

pub type Skills {
  Skills(strength: Int, dexterity: Int, intelligence: Int, charm: Int)
}

pub type Player {
  Player(
    money: Money,
    health: Health,
    energy: Energy,
    weapon: WeaponId,
    location: LocationId,
    job: JobId,
    day_count: Int,
    skills: Skills,
  )
}

// fight

pub type Fight {
  Fight(
    phase: Phase,
    enemy: Enemy,
    flee_pending: Bool,
    last_player_dmg: Option(Int),
    last_enemy_dmg: Option(Int),
  )
}

pub type Phase {
  PlayerTurn
  EnemyTurn
  PlayerWon
  EnemyWon
  PlayerFled
}

// settings 
pub type SettingDisplay {
  Hidden
  SaveLoad
}

pub type Settings {
  Settings(display: SettingDisplay, autosave: Bool, autoload: Bool)
}

// INIT -------------------------------------------------
pub const start_money = 100

pub const start_health = 100

pub const max_health = 100

pub const start_energy = 100

pub const max_energy = 100

fn min_max(v: Int, min: Int, max: Int) {
  v
  |> int.min(max)
  |> int.max(min)
}

// can never go out of bounds [0,100]
pub fn add_energy(current: Energy, v: Int) {
  Energy(current.v + v |> min_max(0, current.max), current.max)
}

// can go negative -> game-over condition
pub fn add_health(current: Health, v: Int) {
  Health(current.v + v |> int.min(current.max), current.max)
}

// can go negative -> debt
pub fn add_money(current: Money, v: Int) -> Money {
  Money(current.v + v)
}

pub fn add_skill(current: Skills, id: SkillId, v: Int) -> Skills {
  case id {
    Charm -> Skills(..current, charm: current.charm + v)
    Dexterity -> Skills(..current, dexterity: current.dexterity + v)
    Intelligence -> Skills(..current, intelligence: current.intelligence + v)
    Strength -> Skills(..current, strength: current.strength + v)
  }
}
