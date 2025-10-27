import env/enemy.{type Enemy, type EnemyId}
import env/shop.{type ConsumableId}
import env/weapon.{type WeaponId}
import env/world.{type LocationId}
import gleam/dict
import gleam/json.{type Json}
import gleam/option.{None, Some}
import gleam/set
import state/state.{
  type Energy, type Fight, type Health, type Inventory, type JobId, type Money,
  type Phase, type Player, type SettingDisplay, type Settings, type Skills,
  type Stamina, type State,
}

pub fn state_to_json(state: State) -> Json {
  let state.State(
    p:,
    fight:,
    buyables:,
    settings:,
    toasts: _,
    active_tooltip: _,
  ) = state
  json.object([
    #("p", player_to_json(p)),
    #("fight", case fight {
      None -> json.null()
      Some(value) -> fight_to_json(value)
    }),
    #("settings", settings_to_json(settings)),
  ])
}

pub fn player_to_json(player: Player) -> Json {
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
  ])
}

pub fn money_to_json(money: Money) -> Json {
  let state.Money(v:) = money
  json.object([#("v", json.int(v))])
}

pub fn health_to_json(health: Health) -> Json {
  let state.Health(v:, max:) = health
  json.object([#("v", json.int(v)), #("max", json.int(max))])
}

pub fn energy_to_json(energy: Energy) -> Json {
  let state.Energy(v:, max:) = energy
  json.object([#("v", json.int(v)), #("max", json.int(max))])
}

pub fn stamina_to_json(stamina: Stamina) -> Json {
  let state.Stamina(v:, max:) = stamina
  json.object([#("v", json.int(v)), #("max", json.int(max))])
}

pub fn weapon_id_to_json(weapon: WeaponId) -> Json {
  case weapon {
    weapon.NoWeapon -> json.string("NoWeapon")
    weapon.BrassKnuckles -> json.string("BrassKnuckles")
  }
}

pub fn location_id_to_json(location: LocationId) -> Json {
  case location {
    world.NoLocation -> json.string("NoLocation")
    world.Apartment -> json.string("Apartment")
    world.Neighbor -> json.string("Neighbor")
    world.BusStop -> json.string("BusStop")
    world.SlingerCorner -> json.string("SlingerCorner")
    world.CityCenter -> json.string("CityCenter")
    world.Gym -> json.string("Gym")
    world.Arms -> json.string("Arms")
    world.GasStation -> json.string("GasStation")
  }
}

pub fn job_id_to_json(job: JobId) -> Json {
  case job {
    state.Lookout -> json.string("Lookout")
    state.Slinger -> json.string("Slinger")
  }
}

pub fn skills_to_json(skills: Skills) -> Json {
  let state.Skills(strength:, dexterity:, intelligence:, charm:) = skills
  json.object([
    #("strength", json.int(strength)),
    #("dexterity", json.int(dexterity)),
    #("intelligence", json.int(intelligence)),
    #("charm", json.int(charm)),
  ])
}

pub fn inventory_to_json(inventory: Inventory) -> Json {
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

pub fn consumable_id_to_json(id: ConsumableId) -> Json {
  case id {
    shop.EnergyDrink -> json.string("EnergyDrink")
    shop.SmallHealthPack -> json.string("SmallHealthPack")
    shop.BigHealthPack -> json.string("BigHealthPack")
  }
}

pub fn fight_to_json(fight: Fight) -> Json {
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

pub fn phase_to_json(phase: Phase) -> Json {
  case phase {
    state.PlayerTurn -> json.string("PlayerTurn")
    state.EnemyTurn -> json.string("EnemyTurn")
    state.PlayerWon -> json.string("PlayerWon")
    state.EnemyWon -> json.string("EnemyWon")
    state.PlayerFled -> json.string("PlayerFled")
  }
}

pub fn enemy_to_json(enemy: Enemy) -> Json {
  let enemy.Enemy(id:, dmg:, def:, crit:, health:, energy:) = enemy
  json.object([
    #("id", enemy_id_to_json(id)),
    #("dmg", json.int(dmg)),
    #("def", json.int(def)),
    #("crit", json.float(crit)),
    #("health", json.int(health)),
    #("energy", json.int(energy)),
  ])
}

pub fn enemy_id_to_json(id: EnemyId) -> Json {
  case id {
    enemy.Lvl1 -> json.string("Lvl1")
    enemy.Lvl2 -> json.string("Lvl2")
  }
}

pub fn settings_to_json(settings: Settings) -> Json {
  let state.Settings(display:, autosave:, autoload:) = settings
  json.object([
    #("display", setting_display_to_json(display)),
    #("autosave", json.bool(autosave)),
    #("autoload", json.bool(autoload)),
  ])
}

pub fn setting_display_to_json(display: SettingDisplay) -> Json {
  case display {
    state.Hidden -> json.string("Hidden")
    state.SaveLoad -> json.string("SaveLoad")
  }
}
