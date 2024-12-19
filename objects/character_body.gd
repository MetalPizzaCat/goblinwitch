extends Node3D
class_name CharacterBody
signal action_animation_finished

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func play_animation(anim : String) -> void:
	animation_player.play(anim)


func _on_animation_player_animation_finished(_anim_name:StringName) -> void:
	action_animation_finished.emit()
