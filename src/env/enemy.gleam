import env/fight_types.{type Crit, type Def, type Dmg, Crit, Def, Dmg}
import env/world.{type LocationId}
import gleam/float
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import util/math

pub type EnemyId {
  Lvl1
  Lvl2
  Lvl10
}

pub type Enemy {
  Enemy(
    id: EnemyId,
    lvl: Int,
    dmg: Dmg,
    def: Def,
    crit: Crit,
    health: Int,
    energy: Int,
  )
}

pub fn get_enemy(id: EnemyId) {
  case id {
    Lvl1 ->
      Enemy(
        id,
        1,
        dmg: 5 |> Dmg,
        def: 0 |> Def,
        crit: 0.05 |> Crit,
        health: 4,
        energy: 50,
      )
    Lvl2 ->
      Enemy(
        id,
        2,
        dmg: 10 |> Dmg,
        def: 0 |> Def,
        crit: 0.15 |> Crit,
        health: 6,
        energy: 50,
      )
    Lvl10 ->
      Enemy(
        id,
        10,
        dmg: 50 |> Dmg,
        def: 10 |> Def,
        crit: 0.25 |> Crit,
        health: 10,
        energy: 100,
      )
  }
  |> assert_bounds
}

pub fn get_victory_reward(e: Enemy) -> Int {
  e.lvl
  |> pure_reward
  |> math.jitter
}

/// pub for (balance-)testing 
pub fn pure_reward(lvl: Int) -> Int {
  let lvl = lvl + 2
  lvl * lvl * 3
}

fn assert_bounds(s: Enemy) -> Enemy {
  let check = fn(b: Bool, err: String) {
    case b {
      False -> panic as { s.id |> string.inspect <> err }
      True -> Nil
    }
  }

  check(s.dmg.v >= 0, "neg dmg")
  check(s.def.v >= 0, "neg def")
  check(s.crit.v >=. 0.0, "neg crit")
  check(s.crit.v <=. 1.0, "more than 100% crit chance")
  check(s.health >= 0, "neg health")
  s
}

pub fn random_location_trouble(id: LocationId) -> Option(EnemyId) {
  let troubles = case id {
    world.BusStop -> [#(0.01, Lvl1)]
    world.DrugCorner -> [#(0.01, Lvl1), #(0.01, Lvl2)]
    _ -> []
  }

  let r = float.random()
  troubles
  |> list.shuffle
  |> list.fold(None, fn(curr, el) {
    let #(chance, enemy) = el
    case r <=. chance && curr |> option.is_none() {
      True -> Some(enemy)
      False -> curr
    }
  })
}
