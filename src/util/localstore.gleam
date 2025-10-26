import gleam/io
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import plinth/javascript/storage
import state/state.{type State}
import state/state_decoder
import state/state_encoder

const key = "last"

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
  |> io.println_error
}

pub fn try_save(state: State) -> State {
  case save(state) {
    Error(e) -> e |> log_e
    Ok(_) -> Nil
  }
  state
}

pub fn try_load() -> Option(State) {
  case load() {
    Error(e) -> {
      e |> log_e
      None
    }
    Ok(s) -> s |> Some
  }
}

fn save(state: State) -> Result(Nil, PersistenceError) {
  use local_storage <- result.try(
    storage.local()
    |> result.replace_error(LocalStoreNotAvailable),
  )

  let json_string =
    state
    |> state_encoder.state_to_json
    |> json.to_string

  storage.set_item(local_storage, key, json_string)
  |> result.replace_error(OperationFailed)
}

fn load() -> Result(State, PersistenceError) {
  use local_storage <- result.try(
    storage.local()
    |> result.replace_error(LocalStoreNotAvailable),
  )

  use json_string <- result.try(
    storage.get_item(local_storage, key)
    |> result.replace_error(NotFound),
  )

  json_string
  |> json.parse(using: state_decoder.state_decoder())
  |> result.replace_error(DecodingFailed)
}

pub fn reset() {
  storage.local() |> result.map(storage.clear)
}
