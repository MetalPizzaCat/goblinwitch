extends Node


@export var narration: Narration
@export var end_narration: Narration
@export var player: PlayerOverworld

@export var end_pos : Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var ambience : AudioStreamPlayer = $Ambience

func activate() -> void:
	
	player.cutscene_paused = true
	await get_tree().create_timer(1).timeout
	ambience.play()
	player.play_narration(narration)
	await player.narrator.narration_over
	player.visible = false
	
	anim.play("trans")
	await anim.animation_finished
	player.cutscene_paused = false
	player.visible = true
	player.is_goblin = true
	player.play_narration(end_narration)
	await player.narrator.narration_over
	ambience.stop()
	player.global_position = end_pos.global_position
