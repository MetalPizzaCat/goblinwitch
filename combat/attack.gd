extends Resource
class_name Attack

enum AttackType {
	## Better at closer range
	MELEE,
	## Better at bigger range
	RANGED
}

enum VisualEffect {
	NONE,
	ARROW,
	MAGIC
}

enum Effect{
	## Does nothing, i am not sure why this would be used
	NONE,
	## Deals 3 damage every turn for 3 turns
	POISON,
	## Deals 3 damage every turn for 3 turns
	FIRE,
	## Removes 1 AP(with min AP being 1) for 2 turns
	SLOWNESS,
}

@export var name: String = "ATK"
@export var description: String
## Damage of the weapon will be modified by this value before applied[br]
## Can be kept as 1 for most attacks
@export var damage_modifier: float = 1.0

@export var is_spell: bool = false

## Determines whether this attack is effective at melee ranged or not
@export var attack_type: AttackType = AttackType.MELEE
@export var effect : VisualEffect = VisualEffect.NONE
## How far can this weapon hit
@export var attack_range: int = 1
## If true this attack can be used on yourself. Meant for healing and similar actions.
@export var can_target_self: bool = false
## How many action points are used by this attack
@export var ap_cost: int = 1
## How much mana is required for this [br]
## Mana doesn't get restored between turns and can only be restored at the start of the combat or using mana potions
@export var mana_cost: int = 1
## Name of the animation to play when using this attack
@export var character_animation_name: String = "punch"
@export_group("Effects")
## Additional effect that will be applied to the target on use
@export var damage_effect : Effect = Effect.NONE
@export var effect_duration : int = 1

@export_group("AI")
@export var is_healing: bool = false
