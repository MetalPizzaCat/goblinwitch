extends AudioStreamPlayer3D
class_name FootstepPlayer

var active : bool = false

func _on_timer_timeout() -> void:
	if active:
		play()

func _on_finished() -> void:
	pass # Replace with function body.
