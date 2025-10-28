import env/weapon.{type WeaponId}
import env/world.{type LocationId, Arms, GasStation}
import gleam/list
import util/either.{type Either}

pub type ConsumableId {
  EnergyDrink
  SmallHealthPack
  BigHealthPack
}

pub const all_consumables = [EnergyDrink, SmallHealthPack, BigHealthPack]

pub type ConsumableEffect {
  ConsumableEffectEnergy(gain: Int)
  ConsumableEffectHealth(gain: Int)
}

pub fn consumable_effect(id: ConsumableId) -> List(ConsumableEffect) {
  case id {
    EnergyDrink -> [ConsumableEffectEnergy(10)]
    SmallHealthPack -> [ConsumableEffectHealth(25)]
    BigHealthPack -> [ConsumableEffectHealth(75)]
  }
}

pub type Buyable {
  Buyable(id: Either(WeaponId, ConsumableId), price: Int, shop: LocationId)
}

pub fn buyables(location: LocationId) -> List(Buyable) {
  all_consumables
  |> list.map(either.from_right)
  |> list.append(
    weapon.all_weapons
    |> list.filter(fn(el) { el != weapon.NoWeapon })
    |> list.map(either.from_left),
  )
  |> list.map(buyables_by_id)
  |> list.filter(fn(b) { b.shop == location })
}

fn buyables_by_id(id: Either(WeaponId, ConsumableId)) {
  case id {
    either.Left(w_id) -> weapon_sale(w_id)
    either.Right(c_id) -> consumable_sale(c_id)
  }
}

pub fn weapon_sale(id: WeaponId) -> Buyable {
  let b = fn(price: Int, shop: LocationId) {
    Buyable(id: either.from_left(id), price:, shop:)
  }
  case id {
    weapon.NoWeapon -> b(0, Arms)
    weapon.BrassKnuckles -> b(300, Arms)
  }
}

pub fn consumable_sale(id: ConsumableId) -> Buyable {
  let b = fn(price: Int, shop: LocationId) {
    Buyable(id: either.from_right(id), price:, shop:)
  }
  case id {
    EnergyDrink -> b(10, GasStation)
    SmallHealthPack -> b(100, GasStation)
    BigHealthPack -> b(200, GasStation)
  }
}
