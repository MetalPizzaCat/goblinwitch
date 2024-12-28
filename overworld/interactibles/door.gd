extends Node3D
class_name Door

@export var is_open: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if is_open:
		animation_player.play_backwards("open")
		await get_tree().create_timer(0.01).timeout
		animation_player.pause()

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