extends Node3D
class_name Overworld

@export var combat_arena: CombatArena
@export var player: PlayerOverworld
@export var game_intro_sequence : Node
@export var play_intro_narration : bool = true  

@onready var combat_arena_storage: Node3D = $CombatArenaStorage
@onready var transition_camera: TransitionCamera = $TransitionCamera


var is_in_combat: bool = false:
	get:
		return _is_in_combat
	set(value):
		_is_in_combat = value
		player.visible = not value
		

var _is_in_combat: bool

func _ready() -> void:
	var combat_areas = get_tree().get_nodes_in_group("combat_area")
	for area in combat_areas:
		area.combat_triggered.connect(_on_combat_triggered)
	if play_intro_narration:
		game_intro_sequence.activate()
	

func start_combat(combat_scenario: CombatScenario, combat_pos: Vector3) -> void:
	combat_arena.position = combat_pos
	combat_arena.load_combat_scenario(combat_scenario)
	is_in_combat = true
	combat_arena.start_combat(player.global_position, player.character)
	combat_arena.visible = true


func _on_combat_triggered(combat: CombatTrigger) -> void:
	transition_camera.current = true
	start_combat(combat.scenario, to_local(combat.combat_spawn_position.global_position))
	transition_camera.move_to(
			to_local(combat_arena.camera.global_position),
			combat_arena.camera.rotation,
			to_local(player.camera.global_position),
			player.camera.global_rotation
		)


func _on_combat_arena_combat_ended() -> void:
	is_in_combat = false
	transition_camera.current = true
	player.global_position = combat_arena.player.global_position
	transition_camera.move_to(
			to_local(player.camera.global_position),
			player.camera.global_rotation,
			to_local(combat_arena.camera.global_position),
			combat_arena.camera.rotation,
		)
	

func _on_transition_camera_finish() -> void:
	player.camera.current = not is_in_combat
	combat_arena.camera.current = is_in_combat
	transition_camera.current = false


func _on_combat_arena_end_sequence_finished() -> void:
	combat_arena.visible = false
	combat_arena.position = combat_arena_storage.position
