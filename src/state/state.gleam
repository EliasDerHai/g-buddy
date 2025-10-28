import env/enemy.{type Enemy}
import env/shop.{type Buyable, type ConsumableId}
import env/weapon.{type WeaponId}
import env/world.{type LocationId}
import gleam/dict.{type Dict}
import gleam/int
import gleam/option.{type Option}
import gleam/set.{type Set}
import state/toast.{type Toast}

pub type State {
  State(
    p: Player,
    // Some == modal fight open
    fight: Option(Fight),
    // non-empty == modal shop open
    buyables: List(Buyable),
    settings: Settings,
    // UI 
    toasts: List(Toast),
    active_tooltip: Option(String),
  )
}

pub type Money {
  Money(v: Int)
}

pub type Health {
  Health(v: Int, max: Int)
}

pub type Energy {
  Energy(v: Int, max: Int)
}

pub type Stamina {
  Stamina(v: Int, max: Int)
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

pub type Inventory {
  Inventory(
    collected_weapons: Set(WeaponId),
    consumables: Dict(ConsumableId, Int),
  )
}

pub type Player {
  Player(
    money: Money,
    health: Health,
    energy: Energy,
    equipped_weapon: WeaponId,
    location: LocationId,
    job: JobId,
    day_count: Int,
    skills: Skills,
    inventory: Inventory,
  )
}

// fight

pub type Fight {
  Fight(
    phase: Phase,
    enemy: Enemy,
    stamina: Stamina,
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

// persistence
pub type GameState {
  GameState(p: Player, fight: Option(Fight))
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
pub fn add_energy(current: Energy, v: Int) -> Energy {
  Energy(current.v + v |> min_max(0, current.max), current.max)
}

pub fn add_stamina(current: Stamina, v: Int) -> Stamina {
  Stamina(current.v + v |> min_max(0, current.max), current.max)
}

pub fn refill_stamina(current: Stamina) {
  Stamina(current.max, current.max)
}

// can go negative -> game-over condition
pub fn add_health(current: Health, v: Int) -> Health {
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

pub fn get_skill(s: Skills, id: SkillId) -> Int {
  case id {
    Charm -> s.charm
    Dexterity -> s.dexterity
    Intelligence -> s.intelligence
    Strength -> s.strength
  }
}
