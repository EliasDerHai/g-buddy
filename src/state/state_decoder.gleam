import env/enemy.{type Enemy, type EnemyId}
import env/world.{type LocationId}
import gleam/dynamic/decode.{type Decoder}
import state/state.{
  type Energy, type Fight, type Health, type JobId, type Money, type Phase,
  type Player, type Skills, type State, type WeaponId,
}

pub fn state_decoder() -> Decoder(State) {
  use p <- decode.field("p", player_decoder())
  use fight <- decode.field("fight", decode.optional(fight_decoder()))
  decode.success(state.State(p:, fight:))
}

pub fn player_decoder() -> Decoder(Player) {
  use money <- decode.field("money", money_decoder())
  use health <- decode.field("health", health_decoder())
  use energy <- decode.field("energy", energy_decoder())
  use weapon <- decode.field("weapon", weapon_id_decoder())
  use location <- decode.field("location", location_id_decoder())
  use job <- decode.field("job", job_id_decoder())
  use day_count <- decode.field("day_count", decode.int)
  use skills <- decode.field("skills", skills_decoder())
  decode.success(state.Player(
    money:,
    health:,
    energy:,
    weapon:,
    location:,
    job:,
    day_count:,
    skills:,
  ))
}

pub fn money_decoder() -> Decoder(Money) {
  use v <- decode.field("v", decode.int)
  decode.success(state.Money(v:))
}

pub fn health_decoder() -> Decoder(Health) {
  use v <- decode.field("v", decode.int)
  use max <- decode.field("max", decode.int)
  decode.success(state.Health(v:, max:))
}

pub fn energy_decoder() -> Decoder(Energy) {
  use v <- decode.field("v", decode.int)
  use max <- decode.field("max", decode.int)
  decode.success(state.Energy(v:, max:))
}

pub fn weapon_id_decoder() -> Decoder(WeaponId) {
  use str <- decode.then(decode.string)
  case str {
    "NoWeapon" -> decode.success(state.NoWeapon)
    "BrassKnuckles" -> decode.success(state.BrassKnuckles)
    _ -> decode.failure(state.NoWeapon, "Invalid WeaponId: " <> str)
  }
}

pub fn location_id_decoder() -> Decoder(LocationId) {
  use str <- decode.then(decode.string)
  case str {
    "NoLocation" -> decode.success(world.NoLocation)
    "Apartment" -> decode.success(world.Apartment)
    "Neighbor" -> decode.success(world.Neighbor)
    "BusStop" -> decode.success(world.BusStop)
    "SlingerCorner" -> decode.success(world.SlingerCorner)
    "CityCenter" -> decode.success(world.CityCenter)
    "Gym" -> decode.success(world.Gym)
    _ -> decode.failure(world.NoLocation, "Invalid LocationId: " <> str)
  }
}

pub fn job_id_decoder() -> Decoder(JobId) {
  use str <- decode.then(decode.string)
  case str {
    "Lookout" -> decode.success(state.Lookout)
    "Slinger" -> decode.success(state.Slinger)
    _ -> decode.failure(state.Lookout, "Invalid JobId: " <> str)
  }
}

pub fn skills_decoder() -> Decoder(Skills) {
  use strength <- decode.field("strength", decode.int)
  use dexterity <- decode.field("dexterity", decode.int)
  use intelligence <- decode.field("intelligence", decode.int)
  use charm <- decode.field("charm", decode.int)
  decode.success(state.Skills(strength:, dexterity:, intelligence:, charm:))
}

pub fn fight_decoder() -> Decoder(Fight) {
  use phase <- decode.field("phase", phase_decoder())
  use enemy <- decode.field("enemy", enemy_decoder())
  use flee_pending <- decode.field("flee_pending", decode.bool)
  use last_player_dmg <- decode.field(
    "last_player_dmg",
    decode.optional(decode.int),
  )
  use last_enemy_dmg <- decode.field(
    "last_enemy_dmg",
    decode.optional(decode.int),
  )
  decode.success(state.Fight(
    phase:,
    enemy:,
    flee_pending:,
    last_player_dmg:,
    last_enemy_dmg:,
  ))
}

pub fn phase_decoder() -> Decoder(Phase) {
  use str <- decode.then(decode.string)
  case str {
    "PlayerTurn" -> decode.success(state.PlayerTurn)
    "EnemyTurn" -> decode.success(state.EnemyTurn)
    "PlayerWon" -> decode.success(state.PlayerWon)
    "EnemyWon" -> decode.success(state.EnemyWon)
    "PlayerFled" -> decode.success(state.PlayerFled)
    _ -> decode.failure(state.PlayerTurn, "Invalid Phase: " <> str)
  }
}

pub fn enemy_decoder() -> Decoder(Enemy) {
  use id <- decode.field("id", enemy_id_decoder())
  use dmg <- decode.field("dmg", decode.int)
  use def <- decode.field("def", decode.int)
  use crit <- decode.field("crit", decode.float)
  use health <- decode.field("health", decode.int)
  use energy <- decode.field("energy", decode.int)
  decode.success(enemy.Enemy(id:, dmg:, def:, crit:, health:, energy:))
}

pub fn enemy_id_decoder() -> Decoder(EnemyId) {
  use str <- decode.then(decode.string)
  case str {
    "Lvl1" -> decode.success(enemy.Lvl1)
    "Lvl2" -> decode.success(enemy.Lvl2)
    _ -> decode.failure(enemy.Lvl1, "Invalid EnemyId: " <> str)
  }
}
