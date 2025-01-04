@tool
extends Node3D
class_name Sublevel

signal finished_loading
signal finished_unloading

@export_file("*.tscn") var level_path: String

@export var is_loaded: bool:
	get:
		return _is_loaded
	set(value):
		if value and level == null:
			load_level()
		elif not value and level != null:
			unload_level()
		_is_loaded = value
		

var _is_loaded: bool = false
var is_loading: bool = false

var level: Level = null
var has_save_data: bool = false
var sublevel_save_data: Dictionary

func load_level() -> void:
	if level != null:
		printerr("Level is already loaded")
		return
	if not ResourceLoader.exists(level_path):
		printerr("Failed to load sublevel %s. Resource not found" % level)
		return
	is_loading = true
	ResourceLoader.load_threaded_request(level_path)

func _process(_delta) -> void:
	if not is_loading:
		return
	match ResourceLoader.load_threaded_get_status(level_path):
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			# notify player somehow but idk how
			pass
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Failed to load %s. Resource is invalid" % level_path)
			is_loading = false
		ResourceLoader.THREAD_LOAD_LOADED:
			is_loading = false
			call_deferred("_add_sub_level")

func _add_sub_level() -> void:
	var scene = ResourceLoader.load_threaded_get(level_path)
	if scene is PackedScene:
		var obj = scene.instantiate()
		if not obj is Level:
			obj.queue_free()
			printerr("Loaded sublevel didn't have Level type")
			return
		level = scene.instantiate()
		add_child(level)
		# required for the level to be loaded in the editor
		if Engine.is_editor_hint():
			level.owner = get_tree().edited_scene_root
		if has_save_data:
			level.load_save_data(sublevel_save_data)
		finished_loading.emit()

func unload_level() -> void:
	if level == null:
		printerr("Attempted to unload level but level is not loaded")
		return
	if not Engine.is_editor_hint():
		# cache in the save data just in case
		sublevel_save_data = level.get_save_data()
		has_save_data = true
	remove_child(level)
	level.queue_free()
	finished_unloading.emit()

func get_save_data() -> Dictionary:
	return sublevel_save_data if level == null else level.get_save_data()

func load_save_data(data: Dictionary) -> void:
	sublevel_save_data = data
	has_save_data = true