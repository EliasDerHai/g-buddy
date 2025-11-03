import env/fight_types.{type Crit, type Dmg, Crit, Dmg}
import gleam/list
import state/state.{type Fight, type Player, type SkillId}

pub type AttackId {
  NormalBlow
  PowerSlam
  KarateKick
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
      )
    KarateKick ->
      AttackMove(
        id:,
        //[#(state.Dexterity, 5)]
        requirements: [],
        stamina_cost: 45,
        dmg: Dmg(3),
        crit: Crit(0.4),
      )
    PowerSlam ->
      AttackMove(
        id:,
        //[#(state.Strength, 5)]
        requirements: [],
        stamina_cost: 60,
        dmg: Dmg(5),
        crit: Crit(0.0),
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
