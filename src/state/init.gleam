import env/enemy.{Lvl1}
import env/world.{Apartment}
import gleam/option.{None, Some}
import state/state.{
  Energy, Fight, Health, Lookout, Money, NoWeapon, Player, PlayerTurn, Skills,
  State,
}

pub fn new_state() {
  State(
    Player(
      Money(state.start_money),
      Health(state.start_health, state.max_health),
      Energy(state.start_energy, state.max_energy),
      NoWeapon,
      Apartment,
      Lookout,
      0,
      Skills(0, 0, 0, 0),
    ),
    None,
    state.Settings(state.Hidden, True, True),
    [],
    None,
  )
}

// for debugging
pub fn new_state_fight() {
  State(
    Player(
      Money(state.start_money),
      Health(state.start_health, state.max_health),
      Energy(state.start_energy, state.max_energy),
      NoWeapon,
      Apartment,
      Lookout,
      0,
      Skills(0, 0, 0, 0),
    ),
    Some(Fight(
      PlayerTurn,
      Lvl1 |> enemy.get_enemy,
      state.Stamina(100, 100),
      False,
      None,
      None,
    )),
    state.Settings(state.Hidden, True, True),
    [],
    None,
  )
}
