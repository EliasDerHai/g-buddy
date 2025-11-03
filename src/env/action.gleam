import env/enemy.{type EnemyId}
import env/fight
import env/world.{type LocationId}
import gleam/list
import state/state.{type Player, type SkillId, type State, Player, State}

// NOTE: don't forget to add new actions
pub type ActionId {
  ActionBusTo(LocationId)
  ActionWorkoutStrength
  ActionWorkoutDexterity
  ActionSleep
  ActionFightClubFight(EnemyId)
}

// NOTE: add here
const all_actions = [
  Action(
    ActionBusTo(world.CityCenter),
    world.BusStop,
    [Money(2)],
    [BusToEffect(world.CityCenter)],
  ),
  Action(
    ActionBusTo(world.BusStop),
    world.CityCenter,
    [Money(2)],
    [BusToEffect(world.BusStop)],
  ),
  Action(
    ActionWorkoutStrength,
    world.Gym,
    [Money(20), Energy(40)],
    [SkillIncreaseEffect(state.Strength, 1)],
  ),
  Action(
    ActionWorkoutDexterity,
    world.Gym,
    [Money(20), Energy(30)],
    [SkillIncreaseEffect(state.Dexterity, 1)],
  ),
  Action(ActionSleep, world.Apartment, [], [SleepEffect]),
  Action(
    ActionFightClubFight(enemy.Lvl1),
    world.FightClub,
    [Energy(30)],
    [FightClubFightEffect(enemy.Lvl1)],
  ),
]

pub type Action {
  Action(
    id: ActionId,
    location: LocationId,
    costs: List(ActionActivationCost),
    special_effects: List(ActionSpecialEffect),
  )
}

pub type ActionActivationCost {
  Energy(cost: Int)
  Money(cost: Int)
}

pub type ActionSpecialEffect {
  BusToEffect(destination: LocationId)
  SkillIncreaseEffect(id: SkillId, increase: Int)
  SleepEffect
  FightClubFightEffect(enemy: EnemyId)
}

pub fn get_action_by_location(location: LocationId) -> List(Action) {
  all_actions |> list.filter(fn(el) { el.location == location })
}

pub fn apply_action(state: State, action: Action) -> State {
  state
  |> state.set_p(state.p |> apply_cost(action.costs))
  |> apply_specials(action.special_effects)
}

fn apply_cost(p: Player, requirements: List(ActionActivationCost)) -> Player {
  list.fold(requirements, p, fn(p, req) {
    case req {
      Money(cost:) -> Player(..p, money: p.money |> state.add_money(-cost))

      Energy(cost:) -> Player(..p, energy: p.energy |> state.add_energy(-cost))
    }
  })
}

fn apply_specials(
  state: State,
  requirements: List(ActionSpecialEffect),
) -> State {
  let p = state.p
  use state, req <- list.fold(requirements, state)
  case req {
    BusToEffect(destination:) ->
      state |> state.set_p(Player(..p, location: destination))
    SleepEffect ->
      state
      |> state.set_p(
        Player(
          ..p,
          energy: state.Energy(p.energy.max, p.energy.max),
          day_count: p.day_count + 1,
        ),
      )
    SkillIncreaseEffect(id:, increase:) ->
      state
      |> state.set_p(
        Player(..p, skills: p.skills |> state.add_skill(id, increase)),
      )
    FightClubFightEffect(enemy:) -> {
      let state.GameState(p:, fight:) = fight.start_fight(enemy, p)
      State(..state, p:) |> state.set_fight(fight)
    }
  }
}
