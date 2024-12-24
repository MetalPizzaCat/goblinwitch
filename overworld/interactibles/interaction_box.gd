extends Node3D
class_name InteractionBox

@export var target: Node

@onready var icon: AnimatedSprite3D = $AnimatedSprite3D
var enabled: bool = true

var is_used: bool:
	get:
		return _is_used
	set(value):
		_is_used = value
		icon.visible = value


var _is_used: bool = false

func _ready() -> void:
	icon.play("default")

func turn_off() -> void:
	enabled = false
	is_used = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerOverworld and enabled:
		is_used = true
		body.interaction_target = target


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is PlayerOverworld:
		is_used = false
		body.interaction_target = null
