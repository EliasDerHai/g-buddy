import env/fight_types.{type Crit, type Def, type Dmg, Crit, Def, Dmg}
import gleam/string

pub type WeaponId {
  NoWeapon
  BrassKnuckles
}

pub const all_weapons = [NoWeapon, BrassKnuckles]

pub type WeaponStat {
  WeaponStat(id: WeaponId, dmg: Dmg, def: Def, crit: Crit)
}

pub fn weapon_stats(id: WeaponId) {
  case id {
    NoWeapon -> WeaponStat(id, dmg: 2 |> Dmg, def: 0 |> Def, crit: 0.0 |> Crit)
    BrassKnuckles ->
      WeaponStat(id, dmg: 3 |> Dmg, def: 0 |> Def, crit: 0.05 |> Crit)
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

  check(s.dmg.v >= 0, "neg dmg")
  check(s.def.v >= 0, "neg def")
  check(s.crit.v >=. 0.0, "neg crit")
  check(s.crit.v <=. 1.0, "more than 100% crit chance")
  s
}
