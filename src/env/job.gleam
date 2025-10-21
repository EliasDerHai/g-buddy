import env/enemy.{type EnemyId}
import gleam/list
import gleam/string
import state/state.{type JobId}

pub type JobStats {
  JobStats(
    id: JobId,
    base_income: Int,
    energy_cost: Int,
    trouble: List(Trouble),
  )
}

pub type Trouble {
  Trouble(chance: Float, enemy: EnemyId)
}

pub fn job_stats(id: JobId) {
  case id {
    state.Lookout ->
      JobStats(id, base_income: 30, energy_cost: 55, trouble: [
        Trouble(0.1, enemy.Lvl1),
      ])
    state.Slinger ->
      JobStats(id, base_income: 30, energy_cost: 55, trouble: [
        Trouble(0.1, enemy.Lvl1),
      ])
  }
  |> assert_bounds
}

fn assert_bounds(s: JobStats) -> JobStats {
  let check = fn(b: Bool, err: String) {
    case b {
      False -> panic as { s.id |> string.inspect <> err }
      True -> Nil
    }
  }

  s.trouble
  |> list.each(fn(trouble) {
    check(trouble.chance >=. 0.0, "neg chance")
    check(trouble.chance <=. 1.0, "more than 100% chance")
  })
  s
}
