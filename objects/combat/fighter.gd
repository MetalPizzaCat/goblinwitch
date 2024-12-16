extends Node3D
class_name Fighter

enum ActionState {
	## No action has been chosen, this pawn is idling
	IDLE,
	## Some action is chosen and that animation for this action is playing[br]
	## This state should exit once animation is over
	PERFORMING,
	## Pawn is moving to a new place and walking animation is playing [br]
	## This state should exist once target is reached
	MOVING
}

## Total action points per each turn
@export var total_ap: int = 3
@export var character: Character:
	get:
		return _character
	set(value):
		_character = value
		if value == null:
			return
		
@export var health: int
@export var arena_position: Vector2i = Vector2i.ZERO:
	get:
		return _arena_position
	set(value):
		_arena_position = value
		if combat_arena != null:
			position = combat_arena.get_cell_local_pos(value) + combat_arena.cell_root.position

@onready var current_ap: int = total_ap
@onready var info_label : Label3D = $InfoLabel

var combat_arena: CombatArena

var _character: Character
var _arena_position: Vector2i
var current_state: ActionState = ActionState.IDLE
var movement_destination: Vector3

## Begin moving this pawn to a given tile
func move_to_tile(pos: Vector2i) -> void:
	if current_state != ActionState.IDLE:
		return
	movement_destination = combat_arena.tile_to_position(pos)
	current_state = ActionState.MOVING
	 
func _process(delta: float) -> void:
	match current_state:
		ActionState.MOVING:
			if position.distance_to(movement_destination) < 0.1:
				position = movement_destination
				movement_destination = Vector3.ZERO
				current_state = ActionState.IDLE
				
			else:
				info_label.text =str(position.distance_to(movement_destination))
				position += position.direction_to(movement_destination).normalized() * combat_arena.fighter_movement_speed * delta
