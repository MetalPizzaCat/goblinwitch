extends Node3D
class_name Dysphoria


signal player_caught

@onready var save_manager: SaveManager = get_node("/root/SaveManager")
@onready var choice_timer: Timer = $BranchTimer

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
var target_branch: int = -1
var final_path_target: int = -1
var kill: bool = false

func start_moving() -> void:
	current_target_id = 0
	active = true
	_set_target(base_path[current_target_id])
	

func pause_movement() -> void:
	active = false
	if not choice_timer.is_stopped():
		choice_timer.paused = true

func unpause_movement() -> void:
	active = true
	if not choice_timer.is_stopped():
		choice_timer.paused = false


func move_to_branch(branch: int) -> void:
	if branch < branches.size():
		_set_target(branches[branch])
		target_branch = branch
		active = true


func _set_target(target: Node3D) -> void:
	movement_time = 0
	start_pos = global_position
	target_pos = target.global_position
	move_distance = start_pos.distance_to(target_pos)
	target_time = move_distance / speed

func _physics_process(delta: float) -> void:
	if not active:
		return
	if kill:
		target_pos = get_tree().get_first_node_in_group("player").global_position
	movement_time += delta
	global_position = start_pos.lerp(target_pos, movement_time / target_time)
	#print("%s/%s = %s" % [movement_time, target_time, start_pos.lerp(target_pos, movement_time / target_time)])
	if abs(movement_time - target_time) < 0.01:
		if kill:
			get_tree().get_first_node_in_group("player").show_failure_screen(true)
			player_caught.emit()
			await get_tree().create_timer(2).timeout
			# force reload last save
			save_manager.load_game()
			return
		movement_time = 0
		if current_target_id + 1 < base_path.size():
			current_target_id += 1
			_set_target(base_path[current_target_id])
		elif target_branch != -1 and final_path_target == -1:
			final_path_target = 0
			_set_target(final_path[final_path_target])
		elif final_path_target > -1 and final_path_target + 1 < final_path.size():
			final_path_target += 1
			_set_target(final_path[final_path_target])
		else:
			active = false
			choice_timer.start()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerOverworld and active:
		body.show_failure_screen(true)
		player_caught.emit()
		await get_tree().create_timer(4).timeout
		# force reload last save
		save_manager.load_game()


func _on_branch_timer_timeout() -> void:
	# kill player if by the time that this timer runs out player has not made a choice
	if target_branch == -1:
		speed = 20
		_set_target(get_tree().get_first_node_in_group("player"))
		kill = true
		active = true
