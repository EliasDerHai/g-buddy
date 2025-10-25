import env/enemy.{type EnemyId, Enemy}
import env/weapon
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import msg.{type FightMove}
import state/state.{
  type Fight, type Phase, type Player, type State, EnemyTurn, EnemyWon, Fight,
  Player, PlayerFled, PlayerTurn, PlayerWon, State,
}

pub fn start_fight(enemy: EnemyId, p: Player) -> Fight {
  let enemy = enemy |> enemy.get_enemy

  let phase = case enemy.energy < p.energy.v {
    True -> PlayerTurn
    False -> EnemyTurn
  }

  Fight(phase, enemy, False, None, None)
}

pub fn player_turn(state: State, move: FightMove) -> State {
  let State(p:, fight:, settings:) = state
  let assert Some(fight) = fight
    as "Illegal state - fight move outside of fight"

  case move {
    msg.Attack -> {
      let assert state.PlayerTurn = fight.phase
        as "Illegal state - cannot attack, not player's turn"

      let weapon.WeaponStat(id: _, dmg:, def: _, crit:) =
        p.weapon |> weapon.weapon_stats
      let real_dmg = dmg_calc(dmg, crit, fight.enemy.def)
      let health = fight.enemy.health - real_dmg

      let enemy = Enemy(..fight.enemy, health:)
      let next_phase = case enemy.health > 0 {
        True -> EnemyTurn
        False -> PlayerWon
      }

      State(
        p:,
        fight: Some(Fight(next_phase, enemy, False, Some(real_dmg), None)),
        settings:,
      )
    }
    msg.Flee ->
      State(
        p:,
        fight: Some(Fight(EnemyTurn, fight.enemy, True, None, None)),
        settings:,
      )
    msg.End -> {
      let assert True = fight.phase |> is_finite_phase as "Illegal state"
      State(p:, fight: None, settings:)
    }
  }
}

pub fn enemy_turn(state: State) -> State {
  let State(p:, fight:, settings:) = state
  let assert Some(fight) = fight
    as "Illegal state - fight move outside of fight"

  let enemy = fight.enemy
  let w_stats = p.weapon |> weapon.weapon_stats
  let real_dmg = dmg_calc(enemy.dmg, enemy.crit, w_stats.def)
  let health = p.health |> state.add_health(-real_dmg)

  let next_phase = case health.v > 0, fight.flee_pending {
    True, True -> PlayerFled
    True, False -> PlayerTurn
    False, _ -> EnemyWon
  }

  State(
    p: Player(..p, health:),
    fight: Some(
      Fight(..fight, phase: next_phase, last_enemy_dmg: Some(real_dmg)),
    ),
    settings:,
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

fn is_finite_phase(phase: Phase) -> Bool {
  [PlayerFled, PlayerWon, EnemyWon] |> list.contains(phase)
}
