import env/job
import state/state.{type Player}

pub fn can_work(p: Player) -> Bool {
  p.energy.v >= { p.job |> job.job_stats }.energy_cost
}
