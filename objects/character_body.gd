extends Node3D
class_name CharacterBody
signal action_animation_finished

enum BodyType {GOBLIN, HUMAN, SKELETON}

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var goblin_body_parts: Array[Node3D] = []
@export var human_body_parts: Array[Node3D] = []
@export var skeleton_body_parts: Array[Node3D] = []
@export var all_body_parts : Array[Node3D] = []

@export var body_type: BodyType:
	get:
		return _body_type
	set(value):
		_enable_body_parts(all_body_parts, false)
		_body_type = value
		match value:
			BodyType.GOBLIN:
				_enable_body_parts(goblin_body_parts, true)
			BodyType.HUMAN:
				_enable_body_parts(human_body_parts, true)
			BodyType.SKELETON:
				_enable_body_parts(skeleton_body_parts, true)
		

var _body_type: BodyType = BodyType.GOBLIN


func play_animation(anim: String) -> void:
	animation_player.play(anim)


func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)

func _enable_body_parts(parts: Array[Node3D], enabled: bool) -> void:
	for part in parts:
		part.visible = enabled
	
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	action_animation_finished.emit()
