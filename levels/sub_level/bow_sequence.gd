extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var activated: bool = false

func activate() -> void:
	animation_player.play("show")

func get_save_data() -> Dictionary:
	return {"act": activated}

func load_save_data(data: Dictionary) -> void:
	activated = data['act']
	if activated:
		animation_player.play("show")
