extends Node3D
class_name Fighter

signal arrow_effect_requested(summoner: Fighter, target: Fighter, magic : bool)
signal action_completed
signal hurt_animation_finished
signal used_action_points(amount: int)
## Event emitted once fighter ended their turn
signal used_all_action_points
signal health_changed
signal died

enum ActionState {
	## No action has been chosen, this pawn is idling
	IDLE,
	## Some action is chosen and that animation for this action is playing[br]
	## This state should exit once animation is over
	PERFORMING,
	## Pawn is moving to a new place and walking animation is playing [br]
	## This state should exist once target is reached
	MOVING,
	## Pawn is playing hurt animation
	HURT,
	DEAD
}

@export var fallback_attacks: Array[Attack]
## Total action points per each turn
@export var total_ap: int = 3
@export var character: Character:
	get:
		return _character
	set(value):
		_character = value
		if value == null:
			return
		health = character.get_max_health()
		current_mana = character.total_mana
		total_ap = character.total_ap
		if anim_body != null:
			remove_child(anim_body)
			anim_body.queue_free()
		print("for %s created %s" % [name, character.model_prefab.resource_path])
		anim_body = character.model_prefab.instantiate() as CharacterBody
		add_child(anim_body)
		anim_body.action_animation_finished.connect(_on_body_action_animation_finished)
		current_state = ActionState.IDLE
		anim_body.set_used_weapon_type(WeaponDisplay.WeaponModel.NONE if character.weapon == null else character.weapon.model)
		
		
@export var health: int

@export var arena_position: Vector2i = Vector2i.ZERO:
	get:
		return _arena_position
	set(value):
		_arena_position = value
		if combat_arena != null:
			position = combat_arena.get_cell_local_pos(value) + combat_arena.cell_root.position

@onready var current_ap: int = total_ap
@onready var info_label: Label3D = $InfoLabel
var anim_body: CharacterBody
@onready var misc_anim_player: AnimationPlayer = $AnimationPlayer
@onready var hit_sound_player: AudioStreamPlayer3D = $HitSoundPlayer

@onready var fire_effect :GPUParticles3D = $FireEffectParticles
@onready var slow_effect : GPUParticles3D = $SlowEffectParticles
@onready var poison_effect : GPUParticles3D = $PoisonEffectParticles

var combat_arena: CombatArena

var is_performing_action: bool:
	get:
		return current_state != ActionState.IDLE

var _character: Character
var _arena_position: Vector2i
var _current_state: ActionState = ActionState.IDLE

var is_dead: bool:
	get:
		return health == 0 or current_state == ActionState.DEAD

var has_finished_all_actions: bool:
	get:
		return current_state == ActionState.DEAD or current_state == ActionState.IDLE

var current_state: ActionState:
	get:
		return _current_state
	set(value):
		_current_state = value
		match value:
			ActionState.MOVING:
				anim_body.play_animation('run')
			ActionState.IDLE:
				anim_body.play_animation('idle')

var movement_destination: Vector3
var movement_destination_cell: Vector2i

var current_mana: int = 0


## What effects fighter has and how many turns have they been going for
var effects: Dictionary = {}

func _ready() -> void:
	$HealSprite.play("default")

	
## Begin moving this pawn to a given tile
func move_to_tile(pos: Vector2i) -> void:
	print("%s moving to %s" % [name, pos])
	if current_state != ActionState.IDLE:
		return
	movement_destination = combat_arena.tile_to_position(pos)
	current_state = ActionState.MOVING
	movement_destination_cell = pos


func _process(delta: float) -> void:
	
	match current_state:
		ActionState.MOVING:
			if position.distance_to(movement_destination) < 0.1:
				position = movement_destination
				movement_destination = Vector3.ZERO
				current_state = ActionState.IDLE
				arena_position = movement_destination_cell
				action_completed.emit()
			else:
				info_label.text = str(position.distance_to(movement_destination))
				
				look_at(combat_arena.to_global(movement_destination))
				position += position.direction_to(movement_destination).normalized() * combat_arena.fighter_movement_speed * delta


func use_ap(amount: int) -> void:
	current_ap = max(0, current_ap - amount)
	used_action_points.emit(amount)
	if current_ap == 0:
		used_all_action_points.emit()

## Reset start of turn values and run all the logic related to applying effects at the start of the term
func start_turn() -> bool:
	current_ap = total_ap
	# simple band-aid to send the event
	used_action_points.emit(0)
	var applying_damage : bool = false
	for effect in effects.keys():
		match effect:
			Attack.Effect.POISON:
				receive_damage(self, 3)
				applying_damage = true
			Attack.Effect.FIRE:
				receive_damage(self, 3)
				applying_damage = true
			Attack.Effect.SLOWNESS:
				# at least let the ai do SOMETHING 
				current_ap = max(current_ap - 1, 1)
		effects[effect] -= 1
		if effects[effect] <= 0:
			effects.erase(effect)
			match effect:
				Attack.Effect.FIRE:
					fire_effect.emitting = false
				Attack.Effect.POISON:
					poison_effect.emitting = false
				Attack.Effect.SLOWNESS:
					slow_effect.emitting = false
	if is_dead:
		used_all_action_points.emit()
	return applying_damage


func add_effect(effect: Attack.Effect, duration: int) -> void:
	if effect == Attack.Effect.NONE:
		return
	effects[effect] = duration
	match effect:
		Attack.Effect.FIRE:
			fire_effect.emitting = true
		Attack.Effect.POISON:
			poison_effect.emitting = true
		Attack.Effect.SLOWNESS:
			slow_effect.emitting = true

func attack(target: Fighter, attack_action: Attack) -> void:
	var target_str = character.weapon.min_strength if character.weapon else 0
	var acc = character.weapon.accuracy if character.weapon else 1
	var dist = target.arena_position.distance_to(arena_position)
	var chance = 1.0
	match attack_action.attack_type:
		Attack.AttackType.MELEE:
			chance = min(1.0, float(character.strength - target_str + character.perception) / (acc * (dist / attack_action.attack_range)))
		Attack.AttackType.RANGED:
			chance = min(1.0, float(character.strength - target_str + character.perception) / (acc * (attack_action.attack_range / dist)))
	use_ap(attack_action.ap_cost)
	if attack_action.is_spell:
		current_mana -= attack_action.mana_cost
	current_state = ActionState.PERFORMING
	anim_body.play_animation(attack_action.character_animation_name)
	look_at(target.global_position)

	match attack_action.effect:
		Attack.VisualEffect.ARROW:
			arrow_effect_requested.emit(self, target, attack_action.is_spell)
			
	target.add_effect(attack_action.damage_effect, attack_action.effect_duration)	
	if combat_arena.arena_rng.randf() < chance:
		var dmg = character.get_melee_damage() * attack_action.damage_modifier
		print("Attacked for %s" % dmg)
		target.receive_damage(self, dmg)
	else:
		misc_anim_player.play("miss")

func receive_damage(dealer: Fighter, damage: int) -> void:
	if dealer != self:
		look_at(dealer.global_position)
	
	health = max(0, health - damage)
	if health == 0:
		anim_body.play_animation("die")
		current_state = ActionState.DEAD
		died.emit()
	else:
		anim_body.play_animation("damage")
		current_state = ActionState.HURT
	health_changed.emit()
	await get_tree().create_timer(0.5).timeout
	hit_sound_player.play()


## Attempt to use item[br]
## This will return false if item is a weapon or EVERY stats that it affects is already at max
func try_use_item(item: Item) -> bool:
	if item.is_weapon:
		return false
	if health < character.get_max_health() and item.health_restore > 0:
		misc_anim_player.play("heal")
	health = min(health + item.health_restore, character.get_max_health())
	current_mana = min(current_mana + item.mana_restore, 3)
	health_changed.emit()
	use_ap(1)
	return true


func get_weapon_attacks() -> Array[Attack]:
	return character.weapon.attacks if character.weapon else fallback_attacks

func _on_body_action_animation_finished() -> void:
	print("Finished anim, current state is %s" % current_state)
	var prev_state = current_state
	current_state = ActionState.IDLE if prev_state != ActionState.DEAD else prev_state
	if prev_state == ActionState.PERFORMING:
		action_completed.emit()
	elif prev_state == ActionState.HURT:
		hurt_animation_finished.emit()
