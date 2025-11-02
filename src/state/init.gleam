import env/enemy.{Lvl1}
import env/weapon.{NoWeapon}
import env/world.{NoLocation}
import gleam/dict
import gleam/option.{None}
import gleam/set
import state/state.{
  Energy, Fight, Health, Inventory, Main, Main01, Money, NoJob, Player,
  PlayerTurn, Skills, State,
}

pub fn new_state() {
  State(new_player(), state.Settings(True, True), state.NoOverlay, [], None)
}

// for debugging
pub fn new_state_fight() {
  State(
    new_player(),
    state.Settings(True, True),
    state.OverlayFight(Fight(
      PlayerTurn,
      Lvl1 |> enemy.get_enemy,
      state.Stamina(100, 100),
      False,
      None,
      None,
    )),
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
    NoLocation,
    NoJob,
    0,
    Skills(0, 0, 0, 0),
    Inventory(set.new(), dict.new()),
    dict.from_list([#(Main, Main01)]),
  )
}
