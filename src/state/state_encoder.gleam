import env/enemy.{type Enemy, type EnemyId}
import env/world.{type LocationId}
import gleam/json.{type Json}
import gleam/option.{None, Some}
import state/state.{
  type Energy, type Fight, type Health, type JobId, type Money, type Phase,
  type Player, type SettingDisplay, type Settings, type Skills, type State,
  type WeaponId,
}

pub fn state_to_json(state: State) -> Json {
  let state.State(p:, fight:, settings:, toasts: _) = state
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
    weapon:,
    location:,
    job:,
    day_count:,
    skills:,
  ) = player
  json.object([
    #("money", money_to_json(money)),
    #("health", health_to_json(health)),
    #("energy", energy_to_json(energy)),
    #("weapon", weapon_id_to_json(weapon)),
    #("location", location_id_to_json(location)),
    #("job", job_id_to_json(job)),
    #("day_count", json.int(day_count)),
    #("skills", skills_to_json(skills)),
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

pub fn weapon_id_to_json(weapon: WeaponId) -> Json {
  case weapon {
    state.NoWeapon -> json.string("NoWeapon")
    state.BrassKnuckles -> json.string("BrassKnuckles")
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

pub fn fight_to_json(fight: Fight) -> Json {
  let state.Fight(
    phase:,
    enemy:,
    flee_pending:,
    last_player_dmg:,
    last_enemy_dmg:,
  ) = fight
  json.object([
    #("phase", phase_to_json(phase)),
    #("enemy", enemy_to_json(enemy)),
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
