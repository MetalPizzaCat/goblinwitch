extends Node3D


@onready var music : AudioStreamPlayer = $Music
@onready var animations : AnimationPlayer = $Control/AnimationPlayer
@onready var save_manager: SaveManager = get_node('/root/SaveManager')
@export var main_level : PackedScene

@export_group("Demo")
@export var demo_mode : bool = false
@export var demo_screen_size : Vector2i = Vector2i(1920,1080)
@export var demo_title : String = "Goblin(DEMO MODE)"

func _ready() -> void:
	music.play()
	if demo_mode:
		get_window().size = demo_screen_size
		get_window().title = demo_title
		animations.play("itch")
		await get_tree().create_timer(10).timeout
		_on_new_game_button_pressed()
	else:
		animations.play("show")
	



func _on_exit_game_button_pressed() -> void:
	get_window().title = "Why did you launch it then? :("
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()


func _on_load_game_button_pressed() -> void:
	save_manager.swap_to_overworld_and_load(main_level)

func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_level)