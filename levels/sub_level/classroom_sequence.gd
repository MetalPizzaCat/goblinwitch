extends Node

@export var sub_level_node_path : String
@onready var level_manager : LevelManager = get_node('/root/LevelManager')

func activate() -> void:
	level_manager.request_level_sub_load(sub_level_node_path)
