extends Node3D
class_name Door

@export var is_open: bool = false


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if is_open:
		animation_player.play("start_open")

func activate() -> void:
	open()
		
## Start the animation sequence for moving the door. If door is already open nothing happens
func open() -> void:
	if is_open:
		return
	is_open = true
	animation_player.play("open")


## activates door closing animation and resets the door flag
func close() -> void:
	if not is_open:
		return
	is_open = false
	animation_player.play("close")

func get_save_data() -> Dictionary:
	return {"open": is_open}


func load_save_data(data: Dictionary) -> void:
	is_open = data['open']
	if is_open:
		animation_player.play("start_open")