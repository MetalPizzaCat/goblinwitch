extends Node3D
class_name LevelChangeTrigger

@export var sub_level : Sublevel

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body is PlayerOverworld:
		sub_level.is_loaded = true
