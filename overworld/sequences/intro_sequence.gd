extends Node

@export var monologue : Narration
var narrator_parent : PlayerOverworld
@export var door : Node3D

func _ready() -> void:
	narrator_parent = get_tree().get_first_node_in_group("player")
	narrator_parent.narrator.narration_over.connect(_on_narration_finished)


func _on_narration_finished() -> void:
	if narrator_parent.narrator.current_narration == monologue:
		door.open()


func activate() -> void:
	narrator_parent.play_narration(monologue)
