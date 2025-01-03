extends Node3D
class_name ArrowAnim

signal finished

@export var start_location: Vector3
@export var end_location: Vector3

@export var speed: float = 30
var moving: bool = false
var time: float = 0

var _is_magic : bool = false
var is_magic : bool:
	get:
		return _is_magic
	set(value):
		_is_magic = false
		arrow_mesh.visible = not value
		magic_sprite.visible = value

@onready var hit_sound : AudioStreamPlayer3D = $HitSound
@onready var arrow_mesh : Node3D = $arrow2
@onready var magic_sprite : AnimatedSprite3D = $MagicSprite

func move(from: Vector3, to: Vector3) -> void:
	start_location = Vector3(from.x, position.y, from.z)
	end_location = Vector3(to.x, position.y, to.z)
	position = start_location
	time = 0
	moving = true

func _ready() -> void:
	magic_sprite.play("default")

func _process(delta: float) -> void:
	if moving:
		position = start_location.lerp(end_location, time * speed / start_location.distance_to(end_location))
		time += delta
		if position.distance_to(end_location) < 0.3:
			moving = false
			finished.emit()
			hit_sound.play()