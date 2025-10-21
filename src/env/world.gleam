import gleam/list
import gleam/result

pub type LocationId {
  NoLocation
  Apartment
  Neighbor
  BusStop
}

const all_location_ids = [NoLocation, Apartment, Neighbor, BusStop]

pub type LocationNode {
  LocationNode(
    id: LocationId,
    // n-e-s-w
    connections: #(LocationId, LocationId, LocationId, LocationId),
  )
}

pub fn get_location(id: LocationId) -> LocationNode {
  let map = fn(id) {
    let #(n, e) = case id {
      // n-e
      NoLocation -> #(NoLocation, NoLocation)
      Apartment -> #(BusStop, NoLocation)
      BusStop -> #(NoLocation, Neighbor)
      Neighbor -> #(NoLocation, NoLocation)
    }
    #(id, n, e)
  }

  let all_partial_nodes = all_location_ids |> list.map(map)
  let #(_, n, e) = map(id)
  let s =
    all_partial_nodes
    |> list.find_map(fn(el) {
      case el.1 {
        x if x == id -> Ok(el.0)
        _ -> Error(Nil)
      }
    })
    |> result.unwrap(NoLocation)
  let w =
    all_partial_nodes
    |> list.find_map(fn(el) {
      case el.2 {
        x if x == id -> Ok(el.0)
        _ -> Error(Nil)
      }
    })
    |> result.unwrap(NoLocation)

  LocationNode(id, #(n, e, s, w))
}

// texts
pub fn label(id: LocationId) -> String {
  case id {
    NoLocation -> "-"
    Apartment -> "Apartment"
    BusStop -> "BusStop"
    Neighbor -> "Neighbor"
  }
}
