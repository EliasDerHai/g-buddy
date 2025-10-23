import gleam/string

pub type EnemyId {
  Lvl1
  Lvl2
}

pub type Enemy {
  Enemy(id: EnemyId, dmg: Int, def: Int, crit: Float, health: Int, energy: Int)
}

pub fn get_enemy(id: EnemyId) {
  case id {
    Lvl1 -> Enemy(id, dmg: 5, def: 0, crit: 0.05, health: 4, energy: 50)
    Lvl2 -> Enemy(id, dmg: 10, def: 0, crit: 0.15, health: 6, energy: 50)
  }
  |> assert_bounds
}

fn assert_bounds(s: Enemy) -> Enemy {
  let check = fn(b: Bool, err: String) {
    case b {
      False -> panic as { s.id |> string.inspect <> err }
      True -> Nil
    }
  }

  check(s.dmg >= 0, "neg dmg")
  check(s.def >= 0, "neg def")
  check(s.crit >=. 0.0, "neg crit")
  check(s.crit <=. 1.0, "more than 100% crit chance")
  check(s.health >= 0, "neg health")
  s
}
