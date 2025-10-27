import env/enemy.{Lvl1}
import env/weapon.{NoWeapon}
import env/world.{Apartment}
import gleam/dict
import gleam/option.{None, Some}
import gleam/set
import state/state.{
  Energy, Fight, Health, Inventory, Lookout, Money, Player, PlayerTurn, Skills,
  State,
}

pub fn new_state() {
  State(new_player(), None, state.Settings(state.Hidden, True, True), [], None)
}

// for debugging
pub fn new_state_fight() {
  State(
    new_player(),
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

fn new_player() {
  Player(
    Money(state.start_money),
    Health(state.start_health, state.max_health),
    Energy(state.start_energy, state.max_energy),
    NoWeapon,
    Apartment,
    Lookout,
    0,
    Skills(0, 0, 0, 0),
    Inventory(set.new(), dict.new()),
  )
}
