extends Node3D

@export var start_node: Node3D
@export var moved_object: Node3D
@export var end_node: Node3D


@export var target_time: float
@export var time: float

func _process(delta: float) -> void:
	if time < target_time:
		time += delta
		moved_object.position = start_node.position.lerp(end_node.position, time / target_time)