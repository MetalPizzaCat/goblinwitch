extends Node3D
class_name CombatCell

signal mouse_over(cell : CombatCell)
signal mouse_leave(cell : CombatCell)
signal mouse_click(cell : CombatCell)

@export var arena_position : Vector2i = Vector2i.ZERO

@onready var mesh: MeshInstance3D = $Tile


func _on_area_3d_mouse_entered() -> void:
	mouse_over.emit(self)


func _on_area_3d_mouse_exited() -> void:
	mouse_leave.emit(self)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var clickEvent = event as InputEventMouseButton
		if clickEvent.button_index == MOUSE_BUTTON_LEFT and clickEvent.pressed:
			mouse_click.emit(self)