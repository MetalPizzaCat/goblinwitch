extends Node3D
class_name WorldButton

## Signal emited when this button is interacted with
signal used

## objects that should be activated by this button
@export var target_objects: Array[Node] = []


func interact(player: PlayerOverworld) -> void:
	for obj in target_objects:
		obj.activate()
	used.emit()
