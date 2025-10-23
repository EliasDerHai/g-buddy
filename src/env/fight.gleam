import env/enemy.{type EnemyId, Enemy}
import env/weapon
import gleam/bool
import gleam/float
import gleam/int
import gleam/option.{None, Some}
import msg.{type FightMove}
import state/state.{
  type Fight, type Player, type State, EnemyTurn, EnemyWon, Fight, Player,
  PlayerTurn, PlayerWon, State,
}

pub fn start_fight(enemy: EnemyId, p: Player) -> Fight {
  let enemy = enemy |> enemy.get_enemy

  let phase = case enemy.energy < p.energy.v {
    True -> PlayerTurn
    False -> EnemyTurn
  }

  Fight(phase, enemy, False)
}

pub fn player_turn(p: Player, fight: Fight, move: FightMove) -> State {
  use <- bool.guard(fight.flee_pending, State(p:, fight: None))

  case move {
    msg.Attack -> {
      let weapon.WeaponStat(id: _, dmg:, def: _, crit:) =
        p.weapon |> weapon.weapon_stats
      let health = fight.enemy.health - dmg_calc(dmg, crit, fight.enemy.def)
      let enemy = Enemy(..fight.enemy, health:)
      let next_phase = case enemy.health > 0 {
        True -> EnemyTurn
        False -> PlayerWon
      }

      State(p:, fight: Some(Fight(next_phase, enemy, False)))
    }
    msg.Flee -> State(p:, fight: Some(Fight(..fight, flee_pending: True)))
  }
}

pub fn enemy_turn(p: Player, fight: Fight) -> State {
  let enemy = fight.enemy
  let w_stats = p.weapon |> weapon.weapon_stats
  let health = p.health.v - dmg_calc(enemy.dmg, enemy.crit, w_stats.def)

  let next_phase = case health > 0 {
    True -> PlayerTurn
    False -> EnemyWon
  }

  State(
    p: Player(..p, health: state.Health(health, p.health.max)),
    fight: Some(Fight(..fight, phase: next_phase)),
  )
}

fn dmg_calc(dmg: Int, crit: Float, def: Int) {
  let crit_multiplier = case float.random() <=. crit {
    True -> 2
    False -> 1
  }

  dmg * crit_multiplier - def
  |> int.max(0)
}
