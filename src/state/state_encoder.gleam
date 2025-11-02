import env/enemy.{type Enemy, type EnemyId}
import env/shop.{type ConsumableId}
import env/weapon.{type WeaponId}
import env/world.{type LocationId}
import gleam/dict
import gleam/json.{type Json}
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import state/state.{
  type Energy, type Fight, type GameState, type Health, type Inventory,
  type JobId, type Money, type Phase, type Player, type Settings, type Skills,
  type Stamina,
}

pub fn settings_to_json(settings: Settings) -> Json {
  let state.Settings(autosave:, autoload:) = settings
  json.object([
    #("autosave", json.bool(autosave)),
    #("autoload", json.bool(autoload)),
  ])
}

pub fn game_state_to_json(game_state: GameState) -> Json {
  let state.GameState(p:, fight:) = game_state
  json.object([
    #("p", player_to_json(p)),
    #("fight", case fight {
      None -> json.null()
      Some(value) -> fight_to_json(value)
    }),
  ])
}

fn player_to_json(player: Player) -> Json {
  let state.Player(
    money:,
    health:,
    energy:,
    equipped_weapon:,
    location:,
    job:,
    day_count:,
    skills:,
    inventory:,
    story:,
  ) = player
  json.object([
    #("money", money_to_json(money)),
    #("health", health_to_json(health)),
    #("energy", energy_to_json(energy)),
    #("weapon", weapon_id_to_json(equipped_weapon)),
    #("location", location_id_to_json(location)),
    #("job", job_id_to_json(job)),
    #("day_count", json.int(day_count)),
    #("skills", skills_to_json(skills)),
    #("inventory", inventory_to_json(inventory)),
    #(
      "story",
      json.array(story |> dict.to_list, fn(pair) {
        let #(line_id, chapter_id) = pair
        json.object([
          #("line_id", story_line_id_to_json(line_id)),
          #("chapter_id", story_chapter_id_to_json(chapter_id)),
        ])
      }),
    ),
  ])
}

fn money_to_json(money: Money) -> Json {
  let state.Money(v:) = money
  json.object([#("v", json.int(v))])
}

fn health_to_json(health: Health) -> Json {
  let state.Health(v:, max:) = health
  json.object([#("v", json.int(v)), #("max", json.int(max))])
}

fn energy_to_json(energy: Energy) -> Json {
  let state.Energy(v:, max:) = energy
  json.object([#("v", json.int(v)), #("max", json.int(max))])
}

fn stamina_to_json(stamina: Stamina) -> Json {
  let state.Stamina(v:, max:) = stamina
  json.object([#("v", json.int(v)), #("max", json.int(max))])
}

fn weapon_id_to_json(weapon: WeaponId) -> Json {
  weapon |> string.inspect |> json.string
}

fn location_id_to_json(location: LocationId) -> Json {
  location |> string.inspect |> json.string
}

fn job_id_to_json(job: JobId) -> Json {
  job |> string.inspect |> json.string
}

fn skills_to_json(skills: Skills) -> Json {
  let state.Skills(strength:, dexterity:, intelligence:, charm:) = skills
  json.object([
    #("strength", json.int(strength)),
    #("dexterity", json.int(dexterity)),
    #("intelligence", json.int(intelligence)),
    #("charm", json.int(charm)),
  ])
}

fn inventory_to_json(inventory: Inventory) -> Json {
  let state.Inventory(collected_weapons:, consumables:) = inventory
  json.object([
    #(
      "collected_weapons",
      json.array(collected_weapons |> set.to_list, weapon_id_to_json),
    ),
    #(
      "consumables",
      json.array(consumables |> dict.to_list, fn(pair) {
        let #(consumable_id, count) = pair
        json.object([
          #("id", consumable_id_to_json(consumable_id)),
          #("count", json.int(count)),
        ])
      }),
    ),
  ])
}

fn consumable_id_to_json(id: ConsumableId) -> Json {
  id |> string.inspect |> json.string
}

fn fight_to_json(fight: Fight) -> Json {
  let state.Fight(
    phase:,
    enemy:,
    stamina:,
    flee_pending:,
    last_player_dmg:,
    last_enemy_dmg:,
  ) = fight
  json.object([
    #("phase", phase_to_json(phase)),
    #("enemy", enemy_to_json(enemy)),
    #("stamina", stamina_to_json(stamina)),
    #("flee_pending", json.bool(flee_pending)),
    #("last_player_dmg", case last_player_dmg {
      None -> json.null()
      Some(value) -> json.int(value)
    }),
    #("last_enemy_dmg", case last_enemy_dmg {
      None -> json.null()
      Some(value) -> json.int(value)
    }),
  ])
}

fn phase_to_json(phase: Phase) -> Json {
  case phase {
    state.PlayerTurn -> json.object([#("type", json.string("PlayerTurn"))])
    state.EnemyTurn -> json.object([#("type", json.string("EnemyTurn"))])
    state.PlayerWon(reward:) ->
      json.object([
        #("type", json.string("PlayerWon")),
        #("reward", json.int(reward)),
      ])
    state.EnemyWon -> json.object([#("type", json.string("EnemyWon"))])
    state.PlayerFled -> json.object([#("type", json.string("PlayerFled"))])
  }
}

fn enemy_to_json(enemy: Enemy) -> Json {
  let enemy.Enemy(id:, lvl:, dmg:, def:, crit:, health:, energy:) = enemy
  json.object([
    #("id", enemy_id_to_json(id)),
    #("lvl", json.int(lvl)),
    #("dmg", json.int(dmg)),
    #("def", json.int(def)),
    #("crit", json.float(crit)),
    #("health", json.int(health)),
    #("energy", json.int(energy)),
  ])
}

fn enemy_id_to_json(id: EnemyId) -> Json {
  id |> string.inspect |> json.string
}

fn story_line_id_to_json(id: state.StoryLineId) -> Json {
  id |> string.inspect |> json.string
}

fn story_chapter_id_to_json(id: state.StoryChapterId) -> Json {
  id |> string.inspect |> json.string
}
