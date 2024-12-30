extends Node3D


@export var narration : Narration
@export var animation_player : AnimationPlayer
@export var door: Door

@export_group("Sequence positions")
@export var horror_tp_pos1 : Node3D
@export var horror_tp_pos2 : Node3D

var player : PlayerOverworld

var old_pos : Vector3

func _on_horror_sequence_trigger_body_entered(body: Node3D) -> void:
	if body is PlayerOverworld:
		player = body
		body.play_narration(narration)
		body.narrator.narration_over.connect(_on_intro_narration_over)
		print("Did anyone catch the game last night?")
		door.close()

func horror_teleport(stage : int) -> void:
	old_pos = player.global_position
	match stage:
		1: 
			player.global_position = horror_tp_pos1.global_position
		2: 
			player.global_position = horror_tp_pos2.global_position

func horror_teleport_back() -> void:
	player.global_position = old_pos

func _on_intro_narration_over() -> void:
	player.narrator.narration_over.disconnect(_on_intro_narration_over)
	animation_player.play("run")


func _on_horror_sequence_start_trigger_body_entered(body:Node3D) -> void:
	if body is PlayerOverworld:
		pass
