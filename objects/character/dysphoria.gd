extends Node3D
class_name Dysphoria


signal player_caught

@onready var save_manager: LevelManager = get_node("/root/LevelManager")

@export var speed: float = 6

@export var base_path: Array[Node3D] = []
@export var branches: Array[Node3D] = []
@export var final_path: Array[Node3D] = []

@export var active: bool = false

var start_pos: Vector3
var target_pos: Vector3
var movement_time: float = 0
var target_time: float = 0
var move_distance: float = 0

var current_target_id: int = -1

func start_moving() -> void:
	current_target_id = 0
	active = true
	_set_target(base_path[current_target_id])
	

func pause_movement() -> void:
	active = false

func unpause_movement() -> void:
	active = true

func _set_target(target: Node3D) -> void:
	start_pos = global_position
	target_pos = target.global_position
	move_distance = start_pos.distance_to(target_pos)
	target_time = move_distance / speed

func _physics_process(delta: float) -> void:
	if not active:
		return
	movement_time += delta
	global_position = start_pos.lerp(target_pos, movement_time / target_time)
	#print("%s/%s = %s" % [movement_time, target_time, start_pos.lerp(target_pos, movement_time / target_time)])
	if abs(movement_time - target_time) < 0.01:
		movement_time = 0
		if current_target_id + 1 < base_path.size():
			current_target_id += 1
			_set_target(base_path[current_target_id])
		else:
			active = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerOverworld and active:
		body.show_failure_screen(true)
		player_caught.emit()
		await get_tree().create_timer(4).timeout
		# force reload last save
		save_manager.load_game()
