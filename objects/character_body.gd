extends Node3D
class_name CharacterBody


@onready var animation_player : AnimationPlayer = $AnimationPlayer

func play_animation(anim : String) -> void:
	animation_player.play(anim)
