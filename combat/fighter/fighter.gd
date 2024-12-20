extends Node3D
class_name Fighter

signal action_completed
signal used_action_points(amount: int)
signal used_all_action_points
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

@export var fallback_attack: Attack
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
@onready var anim_body: CharacterBody = $Body

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


func attack(target: Fighter, attack_action: Attack) -> void:
	var target_str = character.weapon.min_strength if character.weapon else 0
	var acc = character.weapon.accuracy if character.weapon else 1
	var chance = min(1.0, float(character.strength - target_str + character.perception) / acc + 0.1)
	use_ap(attack_action.ap_cost)
	current_state = ActionState.PERFORMING
	anim_body.play_animation(attack_action.character_animation_name)
	look_at(target.global_position)
	if combat_arena.arena_rng.randf() < chance:
		target.receive_damage(self, character.get_melee_damage())
	else:
		print("MISS!")

func receive_damage(dealer: Fighter, damage: int) -> void:
	look_at(dealer.global_position)
	health = max(0, health - damage)
	if health == 0:
		anim_body.play_animation("die")
		current_state = ActionState.DEAD
		died.emit()
	else:
		anim_body.play_animation("damage")
		current_state = ActionState.HURT


func get_weapon_attacks() -> Array[Attack]:
	return character.weapon.attacks if character.weapon else [fallback_attack]

func _on_body_action_animation_finished() -> void:
	print("Finished anim, current state is %s" % current_state)
	var prev_state = current_state
	current_state = ActionState.IDLE
	if prev_state == ActionState.PERFORMING:
		action_completed.emit()
	
