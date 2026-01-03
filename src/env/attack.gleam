import env/fight_types.{type Crit, type Dmg, Crit, Dmg}
import env/weapon.{type WeaponId}
import gleam/list
import state/state.{type Fight, type Player, type SkillId}

pub type AttackId {
  NormalBlow
  PowerSlam
  KarateKick
  BrassBlow
  BrassPowerBlow
}

// NOTE: don't forget to add new AttackIds...
const all_attack_ids = [NormalBlow, PowerSlam, KarateKick]

pub type AttackMove {
  AttackMove(
    id: AttackId,
    requirements: List(#(SkillId, Int)),
    stamina_cost: Int,
    dmg: Dmg,
    crit: Crit,
    weapon: WeaponId,
  )
}

fn get_attack(id: AttackId) {
  case id {
    NormalBlow ->
      AttackMove(
        id:,
        requirements: [],
        stamina_cost: 35,
        dmg: Dmg(1),
        crit: Crit(0.0),
        weapon: weapon.NoWeapon,
      )
    KarateKick ->
      AttackMove(
        id:,
        // TODO: revert [#(state.Dexterity, 5)]
        requirements: [],
        stamina_cost: 45,
        dmg: Dmg(3),
        crit: Crit(0.4),
        weapon: weapon.NoWeapon,
      )
    PowerSlam ->
      AttackMove(
        id:,
        // TODO: revert [#(state.Strength, 5)]
        requirements: [],
        stamina_cost: 60,
        dmg: Dmg(5),
        crit: Crit(0.0),
        weapon: weapon.NoWeapon,
      )
    BrassBlow ->
      AttackMove(
        id:,
        requirements: [],
        stamina_cost: 45,
        dmg: Dmg(3),
        crit: Crit(0.3),
        weapon: weapon.BrassKnuckles,
      )
    BrassPowerBlow ->
      AttackMove(
        id:,
        requirements: [#(state.Strength, 5)],
        stamina_cost: 65,
        dmg: Dmg(8),
        crit: Crit(0.3),
        weapon: weapon.BrassKnuckles,
      )
  }
}

pub fn get_attack_options(p: Player, f: Fight) -> List(AttackMove) {
  all_attack_ids
  |> list.map(get_attack)
  |> list.filter(fn(el) {
    el.requirements
    |> list.all(fn(req) { p.skills |> state.get_skill(req.0) >= req.1 })
    && el.stamina_cost <= f.stamina.v
  })
}
