import env/action.{type ActionActivationCost}
import env/job
import gleam/list
import gleam/option.{type Option, None, Some}
import state/state.{type Player}

pub type DeniedReason {
  Insufficient(ActionActivationCost)
  AlreadyOwned
}

pub fn check_work(p: Player) -> Option(DeniedReason) {
  let energy_cost = { p.job |> job.job_stats }.energy_cost
  case p.energy.v <= energy_cost {
    False -> None
    True -> Some(Insufficient(action.Energy(energy_cost)))
  }
}

pub fn check_action_costs(
  p: Player,
  costs: List(ActionActivationCost),
) -> List(DeniedReason) {
  costs
  |> list.filter_map(fn(cost) {
    case cost {
      action.Energy(amount) ->
        case p.energy.v >= amount {
          True -> Error(Nil)
          False -> Ok(Insufficient(cost))
        }
      action.Money(amount) ->
        case p.money.v >= amount {
          True -> Error(Nil)
          False -> Ok(Insufficient(cost))
        }
    }
  })
}
