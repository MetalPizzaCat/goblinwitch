extends Area3D

@export var bad_dream_pos: Node3D
@export var animation_player: AnimationPlayer

var return_pos: Vector3
var player: PlayerOverworld
var active: bool = true


func return_player() -> void:
	player.cutscene_paused = false
	player.global_position = return_pos


func _on_player_entered(body: Node3D) -> void:
	if body is PlayerOverworld and active:
		player = body
		active = false
		return_pos = player.global_position
		player.cutscene_paused = true
		player.global_position = bad_dream_pos.global_position
		animation_player.play("dream")
		await animation_player.animation_finished
		return_player()

func get_save_data() -> Dictionary:
	return {"active": active}

func load_save_data(data: Dictionary) -> void:
	active = data['active']