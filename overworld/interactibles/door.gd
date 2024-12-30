extends Node3D
class_name Door

@export var is_open: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if is_open:
		animation_player.play("start_open")

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
	animation_player.play("close")