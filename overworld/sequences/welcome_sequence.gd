extends Node

@export var narration : Narration
@export var player : PlayerOverworld

func activate() -> void:
	player.fade_in()
	player.play_narration(narration)