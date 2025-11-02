import env/enemy.{type EnemyId}
import env/world.{type LocationId}
import gleam/float
import gleam/list
import gleam/option.{type Option}
import gleam/string
import state/state.{type JobId}

pub type JobStats {
  JobStats(
    id: JobId,
    base_income: Int,
    energy_cost: Int,
    trouble: List(Trouble),
    workplace: LocationId,
  )
}

pub type Trouble {
  Trouble(chance: Float, enemy: EnemyId)
}

pub fn job_stats(id: JobId) {
  case id {
    state.NoJob ->
      JobStats(
        id,
        base_income: 0,
        energy_cost: 0,
        trouble: [],
        workplace: world.NoLocation,
      )
    state.Lookout ->
      JobStats(
        id,
        base_income: 30,
        energy_cost: 55,
        trouble: [
          Trouble(0.1, enemy.Lvl1),
        ],
        workplace: world.DrugCorner,
      )
    state.Slinger ->
      JobStats(
        id,
        base_income: 40,
        energy_cost: 55,
        trouble: [
          Trouble(0.1, enemy.Lvl1),
          Trouble(0.1, enemy.Lvl2),
        ],
        workplace: world.DrugCorner,
      )
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

pub fn roll_trouble_dice(troubles: List(Trouble)) -> Option(EnemyId) {
  troubles
  |> list.shuffle
  |> list.find(fn(t) { float.random() <=. t.chance })
  |> option.from_result
  |> option.map(fn(o) { o.enemy })
}
