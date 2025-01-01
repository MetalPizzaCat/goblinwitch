extends Node3D
class_name LevelChangeTrigger

@onready var overworld : Overworld = get_tree().get_first_node_in_group("overworld")

@export_file("*.tscn") var level : String

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body is PlayerOverworld:
		overworld.load_sub_level(level)
