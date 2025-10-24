import env/action.{type ActionActivationCost}
import env/job
import gleam/option.{type Option, None, Some}
import state/state.{type Player}

pub type DeniedReason {
  Insufficient(ActionActivationCost)
}

pub fn check_work(p: Player) -> Option(DeniedReason) {
  let energy_cost = { p.job |> job.job_stats }.energy_cost
  case p.energy.v >= energy_cost {
    False -> None
    True -> Some(Insufficient(action.Energy(energy_cost)))
  }
}
