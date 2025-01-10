extends Node3D
class_name WorldButton

## Signal emited when this button is interacted with
signal used

## objects that should be activated by this button
@export var target_objects: Array[Node] = []
@export var one_time_use : bool = true

var was_used : bool = false

func interact(player: PlayerOverworld) -> void:
	if not was_used or not one_time_use:
		was_used = true
		for obj in target_objects:
			if obj != null:
				obj.activate()
		used.emit()


func get_save_data() -> Dictionary:
	return {"active" : was_used}

func load_save_data(data : Dictionary) -> void:
	was_used = data['active']
