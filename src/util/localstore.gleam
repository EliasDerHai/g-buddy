import gleam/io
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import plinth/javascript/storage
import state/state.{type Fight, type GameState, type Player, type Settings}
import state/state_decoder
import state/state_encoder
import util/fun

const settings_key = "settings"

const game_state_key = "game_state"

type PersistenceError {
  LocalStoreNotAvailable
  NotFound
  OperationFailed
  DecodingFailed
}

fn log_e(e: PersistenceError) {
  case e {
    LocalStoreNotAvailable -> "storage not available"
    NotFound -> "stored element not found"
    OperationFailed -> "storage operation failed"
    DecodingFailed -> "decoding stored element failed"
  }
  |> io.println
}

pub fn reset() {
  case storage.local() {
    Error(_) -> Nil
    Ok(storage) ->
      storage
      |> storage.set_item(game_state_key, "")
      |> fun.swallow
  }
}

// Settings persistence -------------------------------

pub fn try_save_settings(settings: Settings) -> Nil {
  case save_settings(settings) {
    Error(e) -> e |> log_e
    Ok(_) -> Nil
  }
}

pub fn try_load_settings() -> Option(Settings) {
  case load_settings() {
    Error(e) -> {
      e |> log_e
      None
    }
    Ok(s) -> Some(s)
  }
}

fn save_settings(settings: Settings) -> Result(Nil, PersistenceError) {
  use local_storage <- result.try(
    storage.local()
    |> result.replace_error(LocalStoreNotAvailable),
  )

  let json_string =
    settings
    |> state_encoder.settings_to_json
    |> json.to_string

  storage.set_item(local_storage, settings_key, json_string)
  |> result.replace_error(OperationFailed)
}

fn load_settings() -> Result(Settings, PersistenceError) {
  use local_storage <- result.try(
    storage.local()
    |> result.replace_error(LocalStoreNotAvailable),
  )

  use json_string <- result.try(
    storage.get_item(local_storage, settings_key)
    |> result.replace_error(NotFound),
  )

  json_string
  |> json.parse(using: state_decoder.settings_decoder())
  |> result.replace_error(DecodingFailed)
}

// Game state persistence ------------------------------

pub fn try_save_game_state(p: Player, fight: Option(Fight)) -> Nil {
  case save_game_state(state.GameState(p:, fight:)) {
    Error(e) -> e |> log_e
    Ok(_) -> Nil
  }
}

pub fn try_load_game_state() -> Option(GameState) {
  case load_game_state() {
    Error(e) -> {
      e |> log_e
      None
    }
    Ok(gs) -> Some(gs)
  }
}

fn save_game_state(game_state: GameState) -> Result(Nil, PersistenceError) {
  use local_storage <- result.try(
    storage.local()
    |> result.replace_error(LocalStoreNotAvailable),
  )

  let json_string =
    game_state
    |> state_encoder.game_state_to_json
    |> json.to_string

  storage.set_item(local_storage, game_state_key, json_string)
  |> result.replace_error(OperationFailed)
}

fn load_game_state() -> Result(GameState, PersistenceError) {
  use local_storage <- result.try(
    storage.local()
    |> result.replace_error(LocalStoreNotAvailable),
  )

  use json_string <- result.try(
    storage.get_item(local_storage, game_state_key)
    |> result.replace_error(NotFound),
  )

  json_string
  |> json.parse(using: state_decoder.game_state_decoder())
  |> result.replace_error(DecodingFailed)
}
