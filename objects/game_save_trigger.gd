extends Node3D

@onready var save_manager: SaveManager = get_node("/root/SaveManager")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerOverworld and not (save_manager.has_loaded and save_manager.save_data['saver'] == get_path()):
		save_manager.save_game(self)
