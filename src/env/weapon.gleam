import gleam/string

pub type WeaponId {
  NoWeapon
  BrassKnuckles
}

pub const all_weapons = [NoWeapon, BrassKnuckles]

pub type WeaponStat {
  WeaponStat(id: WeaponId, dmg: Int, def: Int, crit: Float)
}

pub fn weapon_stats(id: WeaponId) {
  case id {
    NoWeapon -> WeaponStat(id, dmg: 2, def: 0, crit: 0.0)
    BrassKnuckles -> WeaponStat(id, dmg: 3, def: 0, crit: 0.05)
  }
  |> assert_bounds
}

fn assert_bounds(s: WeaponStat) -> WeaponStat {
  let check = fn(b: Bool, err: String) {
    case b {
      False -> panic as { s.id |> string.inspect <> err }
      True -> Nil
    }
  }

  check(s.dmg >= 0, "neg dmg")
  check(s.def >= 0, "neg def")
  check(s.crit >=. 0.0, "neg crit")
  check(s.crit <=. 1.0, "more than 100% crit chance")
  s
}
