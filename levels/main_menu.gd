extends Node3D


@onready var music : AudioStreamPlayer = $Music
@onready var animations : AnimationPlayer = $Control/AnimationPlayer
@onready var save_manager: SaveManager = get_node('/root/SaveManager')
@export var main_level : PackedScene


func _ready() -> void:
	animations.play("show")
	music.play()



func _on_exit_game_button_pressed() -> void:
	get_window().title = "Why did you launch it then? :("
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _on_load_game_button_pressed() -> void:
	save_manager.swap_to_overworld_and_load(main_level)

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_level)