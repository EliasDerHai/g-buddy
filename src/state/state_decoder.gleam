import env/enemy.{type Enemy, type EnemyId}
import env/shop
import env/weapon.{BrassKnuckles, NoWeapon}
import env/world.{type LocationId}
import gleam/dict
import gleam/dynamic/decode.{type Decoder}
import gleam/set
import state/state.{
  type Energy, type Fight, type GameState, type Health, type Inventory,
  type JobId, type Money, type Phase, type Player, type Settings, type Skills,
  type Stamina,
}

pub fn settings_decoder() -> Decoder(Settings) {
  use autosave <- decode.field("autosave", decode.bool)
  use autoload <- decode.field("autoload", decode.bool)
  decode.success(state.Settings(autosave:, autoload:))
}

pub fn game_state_decoder() -> Decoder(GameState) {
  use p <- decode.field("p", player_decoder())
  use fight <- decode.field("fight", decode.optional(fight_decoder()))
  decode.success(state.GameState(p:, fight:))
}

fn player_decoder() -> Decoder(Player) {
  use money <- decode.field("money", money_decoder())
  use health <- decode.field("health", health_decoder())
  use energy <- decode.field("energy", energy_decoder())
  use equipped_weapon <- decode.field("weapon", weapon_id_decoder())
  use location <- decode.field("location", location_id_decoder())
  use job <- decode.field("job", job_id_decoder())
  use day_count <- decode.field("day_count", decode.int)
  use skills <- decode.field("skills", skills_decoder())
  use inventory <- decode.field("inventory", inventory_decoder())
  use story <- decode.field("story", decode.list(story_entry_decoder()))

  let story_dict = story |> dict.from_list

  decode.success(state.Player(
    money:,
    health:,
    energy:,
    equipped_weapon:,
    location:,
    job:,
    day_count:,
    skills:,
    inventory:,
    story: story_dict,
  ))
}

fn money_decoder() -> Decoder(Money) {
  use v <- decode.field("v", decode.int)
  decode.success(state.Money(v:))
}

fn health_decoder() -> Decoder(Health) {
  use v <- decode.field("v", decode.int)
  use max <- decode.field("max", decode.int)
  decode.success(state.Health(v:, max:))
}

fn energy_decoder() -> Decoder(Energy) {
  use v <- decode.field("v", decode.int)
  use max <- decode.field("max", decode.int)
  decode.success(state.Energy(v:, max:))
}

fn stamina_decoder() -> Decoder(Stamina) {
  use v <- decode.field("v", decode.int)
  use max <- decode.field("max", decode.int)
  decode.success(state.Stamina(v:, max:))
}

fn weapon_id_decoder() -> Decoder(weapon.WeaponId) {
  use str <- decode.then(decode.string)
  case str {
    "NoWeapon" -> decode.success(NoWeapon)
    "BrassKnuckles" -> decode.success(BrassKnuckles)
    _ -> decode.failure(NoWeapon, "Invalid WeaponId: " <> str)
  }
}

fn location_id_decoder() -> Decoder(LocationId) {
  use str <- decode.then(decode.string)
  case str {
    "NoLocation" -> decode.success(world.NoLocation)
    "Apartment" -> decode.success(world.Apartment)
    "Neighbor" -> decode.success(world.Neighbor)
    "BusStop" -> decode.success(world.BusStop)
    "DrugCorner" -> decode.success(world.DrugCorner)
    "CityCenter" -> decode.success(world.CityCenter)
    "Gym" -> decode.success(world.Gym)
    "GasStation" -> decode.success(world.GasStation)
    "Arms" -> decode.success(world.Arms)
    _ -> decode.failure(world.NoLocation, "Invalid LocationId: " <> str)
  }
}

fn job_id_decoder() -> Decoder(JobId) {
  use str <- decode.then(decode.string)
  case str {
    "NoJob" -> decode.success(state.NoJob)
    "Lookout" -> decode.success(state.Lookout)
    "Slinger" -> decode.success(state.Slinger)
    _ -> decode.failure(state.NoJob, "Invalid JobId: " <> str)
  }
}

fn skills_decoder() -> Decoder(Skills) {
  use strength <- decode.field("strength", decode.int)
  use dexterity <- decode.field("dexterity", decode.int)
  use intelligence <- decode.field("intelligence", decode.int)
  use charm <- decode.field("charm", decode.int)
  decode.success(state.Skills(strength:, dexterity:, intelligence:, charm:))
}

fn inventory_decoder() -> Decoder(Inventory) {
  use collected_weapons <- decode.field(
    "collected_weapons",
    decode.list(weapon_id_decoder()),
  )
  use consumables <- decode.field(
    "consumables",
    decode.list(consumable_entry_decoder()),
  )

  let weapons_set = collected_weapons |> set.from_list
  let consumables_dict = consumables |> dict.from_list

  decode.success(state.Inventory(
    collected_weapons: weapons_set,
    consumables: consumables_dict,
  ))
}

fn consumable_entry_decoder() -> Decoder(#(shop.ConsumableId, Int)) {
  use id <- decode.field("id", consumable_id_decoder())
  use count <- decode.field("count", decode.int)
  decode.success(#(id, count))
}

fn consumable_id_decoder() -> Decoder(shop.ConsumableId) {
  use str <- decode.then(decode.string)
  case str {
    "EnergyDrink" -> decode.success(shop.EnergyDrink)
    "SmallHealthPack" -> decode.success(shop.SmallHealthPack)
    "BigHealthPack" -> decode.success(shop.BigHealthPack)
    _ -> decode.failure(shop.EnergyDrink, "Invalid ConsumableId: " <> str)
  }
}

fn fight_decoder() -> Decoder(Fight) {
  use phase <- decode.field("phase", phase_decoder())
  use enemy <- decode.field("enemy", enemy_decoder())
  use stamina <- decode.field("stamina", stamina_decoder())
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
    stamina:,
    flee_pending:,
    last_player_dmg:,
    last_enemy_dmg:,
  ))
}

fn phase_decoder() -> Decoder(Phase) {
  use phase_type <- decode.field("type", decode.string)
  case phase_type {
    "PlayerTurn" -> decode.success(state.PlayerTurn)
    "EnemyTurn" -> decode.success(state.EnemyTurn)
    "PlayerWon" -> {
      use reward <- decode.field("reward", decode.int)
      decode.success(state.PlayerWon(reward:))
    }
    "EnemyWon" -> decode.success(state.EnemyWon)
    "PlayerFled" -> decode.success(state.PlayerFled)
    _ -> decode.failure(state.PlayerTurn, "Invalid Phase: " <> phase_type)
  }
}

fn enemy_decoder() -> Decoder(Enemy) {
  use id <- decode.field("id", enemy_id_decoder())
  use lvl <- decode.field("lvl", decode.int)
  use dmg <- decode.field("dmg", decode.int)
  use def <- decode.field("def", decode.int)
  use crit <- decode.field("crit", decode.float)
  use health <- decode.field("health", decode.int)
  use energy <- decode.field("energy", decode.int)
  decode.success(enemy.Enemy(id:, lvl:, dmg:, def:, crit:, health:, energy:))
}

fn enemy_id_decoder() -> Decoder(EnemyId) {
  use str <- decode.then(decode.string)
  case str {
    "Lvl1" -> decode.success(enemy.Lvl1)
    "Lvl2" -> decode.success(enemy.Lvl2)
    "Lvl10" -> decode.success(enemy.Lvl10)
    _ -> decode.failure(enemy.Lvl1, "Invalid EnemyId: " <> str)
  }
}

fn story_line_id_decoder() -> Decoder(state.StoryLineId) {
  use str <- decode.then(decode.string)
  case str {
    "Main" -> decode.success(state.Main)
    _ -> decode.failure(state.Main, "Invalid StoryLineId: " <> str)
  }
}

fn story_chapter_id_decoder() -> Decoder(state.StoryChapterId) {
  use str <- decode.then(decode.string)
  case str {
    "Main01" -> decode.success(state.Main01)
    "Main02" -> decode.success(state.Main02)
    "Placeholder" -> decode.success(state.Placeholder)
    _ -> decode.failure(state.Main01, "Invalid StoryChapterId: " <> str)
  }
}

fn story_entry_decoder() -> Decoder(#(state.StoryLineId, state.StoryChapterId)) {
  use line_id <- decode.field("line_id", story_line_id_decoder())
  use chapter_id <- decode.field("chapter_id", story_chapter_id_decoder())
  decode.success(#(line_id, chapter_id))
}
