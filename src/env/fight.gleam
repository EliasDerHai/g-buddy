import env/enemy.{type EnemyId, Enemy}
import env/weapon
import gleam/float
import gleam/int
import gleam/option.{None, Some}
import msg.{type FightMove}
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
  let fight =
    Fight(phase, enemy, Stamina(max_stamina, max_stamina), False, None, None)

  case phase {
    EnemyTurn -> enemy_turn(p, fight)
    _ -> GameState(p:, fight: Some(fight))
  }
}

pub fn player_turn(p: Player, fight: Fight, move: FightMove) -> GameState {
  case move {
    msg.FightAttack(move) -> {
      let assert state.PlayerTurn = fight.phase
        as "Illegal state - cannot attack, not player's turn"
      let assert True = move.stamina_cost <= fight.stamina.v
        as "Illegal state - not enough stamina"

      let weapon.WeaponStat(id: _, dmg:, def: _, crit:) =
        p.equipped_weapon |> weapon.weapon_stats
      let real_dmg = dmg_calc(dmg, crit, fight.enemy.def)
      let health = fight.enemy.health - real_dmg
      let stamina = fight.stamina |> state.add_stamina(-move.stamina_cost)

      let enemy = Enemy(..fight.enemy, health:)
      let next_phase = case enemy.health > 0 {
        True -> EnemyTurn
        False -> PlayerWon(reward: enemy.get_victory_reward(enemy))
      }

      let fight =
        Some(
          Fight(
            ..fight,
            phase: next_phase,
            enemy:,
            stamina:,
            last_player_dmg: Some(real_dmg),
          ),
        )

      GameState(p:, fight:)
    }
    msg.FightRegenStamina ->
      GameState(
        p:,
        fight: Some(
          Fight(
            ..fight,
            phase: EnemyTurn,
            stamina: fight.stamina |> state.refill_stamina,
            last_player_dmg: None,
          ),
        ),
      )
    msg.FightFlee ->
      GameState(
        p:,
        fight: Some(
          Fight(
            ..fight,
            phase: EnemyTurn,
            flee_pending: True,
            last_player_dmg: None,
          ),
        ),
      )
    msg.FightEnd -> {
      let assert True = fight.phase |> is_finite_phase as "Illegal state"

      let p = case fight.phase {
        PlayerWon(reward:) ->
          Player(..p, money: p.money |> state.add_money(reward))
        _ -> p
      }

      GameState(p:, fight: None)
    }
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

fn dmg_calc(dmg: Int, crit: Float, def: Int) -> Int {
  let crit_multiplier = case float.random() <=. crit {
    True -> 2
    False -> 1
  }

  dmg * crit_multiplier - def
  |> int.max(0)
}

fn is_finite_phase(phase: Phase) -> Bool {
  case phase {
    EnemyWon | PlayerFled | PlayerWon(_) -> True
    _ -> False
  }
}
