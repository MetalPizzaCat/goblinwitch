extends Node
class_name levelManager

signal started_game_save

var save_file_name = "goblin.save"

@onready var overworld_path: String = ProjectSettings.get_setting('application/run/main_scene')

## Flag that is set to true every time a save is loaded
var has_loaded: bool = false
var save_data: Dictionary

func save_game(saver: Node = null) -> void:
	started_game_save.emit()
	var save_file = FileAccess.open("user://%s" % save_file_name, FileAccess.WRITE)
	var overworld: Overworld = get_tree().get_first_node_in_group("overworld")
	var saveable = get_tree().get_nodes_in_group("main_save")
	var save_data: Dictionary = {'overworld': overworld.get_save_data()}
	if saver != null:
		save_data['saver'] = saver.get_path()
	save_file.store_var(save_data)


func load_game() -> void:
	get_tree().reload_current_scene()
	var save_file = FileAccess.open("user://%s" % save_file_name, FileAccess.READ)
	has_loaded = true
	save_data = save_file.get_var()
	print(save_data)
