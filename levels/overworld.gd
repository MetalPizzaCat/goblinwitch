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

@onready var level_manager: LevelManager = get_node('/root/LevelManager')
@onready var intro_sublevel: Level = $SubLevelIntro

var currently_loading_level: String
var is_loading_level: bool
var sub_level: Level

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
	if level_manager.has_loaded:
		load_save_data(level_manager.save_data['overworld'])
	var combat_areas = get_tree().get_nodes_in_group("combat_area")
	for area in combat_areas:
		area.combat_triggered.connect(_on_combat_triggered)
	if play_intro_narration:
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

func load_sub_level(path: String) -> void:
	if ResourceLoader.exists(path):
		if sub_level != null:
			remove_child(sub_level)
			sub_level.queue_free()
		currently_loading_level = path
		is_loading_level = true
		ResourceLoader.load_threaded_request(path)
	else:
		printerr("attempted to load invalid level: %s" % path)

func _process(_delta: float) -> void:
	if is_loading_level:
		match ResourceLoader.load_threaded_get_status(currently_loading_level):
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				interface_animations.play("load")
				loading_interface.visible = true
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				printerr("Failed to load")
			ResourceLoader.THREAD_LOAD_LOADED:
				loading_interface.visible = false
				is_loading_level = false
				call_deferred("_add_sub_level")


func _add_sub_level() -> void:
	var level = ResourceLoader.load_threaded_get(currently_loading_level)
	if level is PackedScene:
		sub_level = level.instantiate()
		add_child(sub_level)
		sublevel_loaded.emit()


func get_save_data() -> Dictionary:
	return {
			"finished_intro": intro_unloaded,
		 	"finished_welcome": welcome_played,
			"has_sublevel": sub_level != null,
			"sublevel": currently_loading_level,
			"player": player.get_save_data(),
			"sublevel_data": intro_sublevel.get_save_data() if sub_level == null else sub_level.get_save_data()
		}


func load_save_data(data: Dictionary) -> void:
	intro_unloaded = data['finished_intro']
	welcome_played = data['finished_welcome']
	if data['has_sublevel']:
		load_sub_level(data['sublevel'])
		await sublevel_loaded
		sub_level.load_save_data(data['sublevel_data'])
	else:
		intro_sublevel.load_save_data(data['sublevel_data'])
	player.load_save_data(data['player'])
	

func _on_load_button_pressed() -> void:
	level_manager.load_game()

func _on_save_button_pressed() -> void:
	level_manager.save_game()
