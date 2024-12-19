extends Resource
class_name Attack

enum AttackType {MELEE, RANGED}

@export var name: String = "GENERIC_ATTACK_NAME"
## Damage of the weapon will be modified by this value before applied[br]
## Can be kept as 1 for most attacks
@export var damage_modifier: float = 1.0

@export var is_spell: bool = false

@export var attack_type: AttackType = AttackType.MELEE
## If true this attack can be used on yourself. Meant for healing and similar actions.
@export var can_target_self: bool = false
## How many action points are used by this attack
@export var ap_cost: int = 1
## Name of the animation to play when using this attack
@export var character_animation_name: String = "punch"
