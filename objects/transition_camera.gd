extends Camera3D
class_name TransitionCamera

signal finish

@export var destination: Vector3
@export var target_rotation: Vector3
@export var finished: bool = true
@export var transition_time: float = 2

var start_pos: Vector3
var start_rotation: Vector3

var current_time: float = 0

func move_to(to_pos: Vector3, to_rot: Vector3, from_pos: Vector3, from_rot: Vector3) -> void:
	finished = false
	destination = to_pos
	target_rotation = to_rot
	start_pos = from_pos
	start_rotation = from_rot
	current_time = 0

func _process(delta: float) -> void:
	if finished:
		return
	current_time += delta
	if current_time > transition_time:
		finished = true
		finish.emit()
		return
	position = start_pos.lerp(destination, current_time / transition_time)
	rotation = start_rotation.lerp(target_rotation, current_time / transition_time)
