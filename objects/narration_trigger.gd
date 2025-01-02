extends Area3D

@export var narration: Narration
@export var one_time: bool = true
var was_used: bool = false

func _ready() -> void:
	body_entered.connect(_start_narration)


func _start_narration(body: Node3D) -> void:
	if body is PlayerOverworld and narration != null and not was_used:
		body.play_narration(narration)
		if one_time:
			was_used = true

func get_save_data() -> Dictionary:
	return {"used": was_used}


func load_save_data(data : Dictionary) -> void:
	was_used = data['used']