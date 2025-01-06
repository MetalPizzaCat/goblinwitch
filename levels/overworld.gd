extends Node3D
class_name Overworld

signal sublevel_loaded

@export var combat_arena: CombatArena
@export var player: PlayerOverworld
@export var game_intro_sequence: Node
@export var play_intro_narration: bool = true
@export var level_transition_box: Node3D

@onready var combat_arena_storage: Node3D = $CombatArenaStorage
@onready var transition_camera: TransitionCamera = $TransitionCamera
@onready var loading_interface: Control = $Interface/LoadingInterface
@onready var interface_animations: AnimationPlayer = $Interface/AnimationPlayer

@onready var save_manager: SaveManager = get_node('/root/SaveManager')
@onready var intro_sublevel: Level = $SubLevelIntro

var currently_loading_level: String
var is_loading_level: bool

var intro_unloaded: bool = false
var welcome_played: bool = false

var is_in_combat: bool = false:
	get:
		return _is_in_combat
	set(value):
		_is_in_combat = value
		player.visible = not value
		

var _is_in_combat: bool

func _ready() -> void:
	save_manager.started_game_save.connect(_on_game_save_started)
	if save_manager.has_loaded:
		load_save_data(save_manager.save_data['overworld'])
	var combat_areas = get_tree().get_nodes_in_group("combat_area")
	for area in combat_areas:
		area.combat_triggered.connect(_on_combat_triggered)
	if play_intro_narration and not welcome_played:
		game_intro_sequence.activate()
		welcome_played = true
	

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


func _on_sub_level_intro_horror_event_started() -> void:
	$AmbientSoundPlayer.stop()


func _on_sub_level_intro_horror_event_ended() -> void:
	print("over!")
	player.global_position = level_transition_box.global_position
	$AmbientSoundPlayer.play()
	player.cutscene_paused = false
	remove_child(intro_sublevel)
	intro_sublevel.queue_free()
	intro_sublevel = null


func get_save_data() -> Dictionary:
	return {
			"finished_intro": intro_unloaded,
		 	"finished_welcome": welcome_played,
			"sublevels": get_tree().get_nodes_in_group("sublevel").map(func(p): return {'node': p.name, 'data': p.get_save_data(), 'loaded' : p.is_loaded}),
			"player": player.get_save_data(),
			"intro_data": intro_sublevel.get_save_data(),
			"has_intro": intro_sublevel != null
		}


func _on_game_save_started() -> void:
	interface_animations.play("save")

func load_save_data(data: Dictionary) -> void:
	intro_unloaded = data['finished_intro']
	welcome_played = data['finished_welcome']
	for sublevel in data['sublevels']:
		var sub = get_node(str(sublevel['node'])) as Sublevel
		sub.load_save_data(sublevel['data'])
		sub.is_loaded = sublevel['loaded']
	if data['has_intro']:
		intro_sublevel.load_save_data(data['intro_data'])
	else:
		remove_child(intro_sublevel)
		intro_sublevel.queue_free()
		intro_sublevel = null
	player.load_save_data(data['player'])
	

func _on_load_button_pressed() -> void:
	save_manager.load_game()

func _on_save_button_pressed() -> void:
	save_manager.save_game()


func _on_combat_arena_player_lost() -> void:
	player.die()
