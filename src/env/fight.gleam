import env/enemy.{type EnemyId}
import env/fight_types.{type Crit, type Def, type Dmg}
import env/weapon
import gleam/float
import gleam/int
import gleam/option.{None, Some}
import state/state.{
  type Fight, type GameState, type Phase, type Player, EnemyTurn, EnemyWon,
  Fight, GameState, Player, PlayerFled, PlayerTurn, PlayerWon, Stamina,
}

pub fn start_fight(enemy: EnemyId, p: Player) -> GameState {
  let enemy = enemy |> enemy.get_enemy

  let phase = case enemy.energy < p.energy.v {
    True -> PlayerTurn
    False -> EnemyTurn
  }

  let max_stamina = p.skills.dexterity + p.energy.v + 100
  let stamina = Stamina(max_stamina, max_stamina)
  let fight = Fight(phase, enemy, stamina, False, None, None)

  case phase {
    EnemyTurn -> enemy_turn(p, fight)
    _ -> GameState(p:, fight: Some(fight))
  }
}

pub fn enemy_turn(p: Player, fight: Fight) -> GameState {
  let enemy = fight.enemy
  let w_stats = p.equipped_weapon |> weapon.weapon_stats
  let real_dmg = dmg_calc(enemy.dmg, enemy.crit, w_stats.def)
  let health = p.health |> state.add_health(-real_dmg)

  let next_phase = case health.v > 0, fight.flee_pending {
    True, True -> PlayerFled
    True, False -> PlayerTurn
    False, _ -> EnemyWon
  }

  GameState(
    p: Player(..p, health:),
    fight: Some(
      Fight(..fight, phase: next_phase, last_enemy_dmg: Some(real_dmg)),
    ),
  )
}

pub fn dmg_calc(dmg: Dmg, crit: Crit, def: Def) -> Int {
  let crit_multiplier = case float.random() <=. crit.v {
    True -> 2
    False -> 1
  }

  dmg.v * crit_multiplier - def.v |> int.max(0)
}

pub fn is_finite_phase(phase: Phase) -> Bool {
  case phase {
    EnemyWon | PlayerFled | PlayerWon(_) -> True
    _ -> False
  }
}
