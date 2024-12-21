extends Area3D
class_name NarrationTrigger

@export var enabled : bool = true
@export var narration : Narration

func _on_body_entered(body:Node3D) -> void:
	if body is PlayerOverworld and enabled:
		body.play_narration(narration)
		enabled = false
