extends Node3D
class_name Door

@export var is_open: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func activate() -> void:
	open()
		

func open() -> void:
	if is_open:
		return
	is_open = true
	animation_player.play("open")

func close() -> void:
	if not is_open:
		return
	is_open = false
	animation_player.play_backwards("open")