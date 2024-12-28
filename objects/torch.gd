extends Node3D
class_name Torch

@onready var sprite : AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	sprite.play("default")