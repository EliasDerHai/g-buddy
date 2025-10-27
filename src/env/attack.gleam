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
  )
}

fn get_attack(id: AttackId) {
  case id {
    NormalBlow -> AttackMove(id:, requirements: [], stamina_cost: 35)
    KarateKick ->
      AttackMove(
        id:,
        //[#(state.Dexterity, 5)]
        requirements: [],
        stamina_cost: 45,
      )
    PowerSlam ->
      AttackMove(
        id:,
        //[#(state.Strength, 5)]
        requirements: [],
        stamina_cost: 60,
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
