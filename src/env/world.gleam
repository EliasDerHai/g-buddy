import gleam/list
import gleam/result

// MAP LAYOUT (n-e-s-w connections)
// ================================
//
//                                SlingerCorner
//                                      |
//                                      |
//                          -------- BusStop -------- Neighbor
//                                      |
//                                      |
//                                  Apartment
//
//                                
//                                      |
//                                      |
//                          -------- CityCenter-------- Gym
//                                      |
//                                      |
//                                  
//
// To add a location:
// 1. Add it to LocationId enum
// 2. Add it to all_location_ids list
// 3. Add its (north, east) connections in the map function below
// 4. Update this ASCII diagram

pub type LocationId {
  NoLocation
  Apartment
  Neighbor
  BusStop
  SlingerCorner

  CityCenter
  Gym
}

const all_location_ids = [
  NoLocation,
  Apartment,
  Neighbor,
  BusStop,
  SlingerCorner,
  CityCenter,
  Gym,
]

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
      BusStop -> #(SlingerCorner, Neighbor)
      Neighbor -> #(NoLocation, NoLocation)
      SlingerCorner -> #(NoLocation, NoLocation)
      CityCenter -> #(NoLocation, Gym)
      Gym -> #(NoLocation, NoLocation)
    }
    #(id, n, e)
  }

  let all_partial_nodes = all_location_ids |> list.map(map)
  let #(_, n, e) = map(id)
  let s =
    all_partial_nodes
    |> list.find_map(fn(el) {
      case el.1 == id {
        True -> Ok(el.0)
        False -> Error(Nil)
      }
    })
    |> result.unwrap(NoLocation)
  let w =
    all_partial_nodes
    |> list.find_map(fn(el) {
      case el.2 == id {
        True -> Ok(el.0)
        False -> Error(Nil)
      }
    })
    |> result.unwrap(NoLocation)

  LocationNode(id, #(n, e, s, w))
}
