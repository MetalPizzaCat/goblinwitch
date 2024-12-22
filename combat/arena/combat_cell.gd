extends Node3D
class_name CombatCell

signal mouse_over(cell: CombatCell)
signal mouse_leave(cell: CombatCell)
signal mouse_click(cell: CombatCell)

enum TileState {DEFAULT, WARNING, GOOD, BAD}

@export var arena_position: Vector2i = Vector2i.ZERO

@export_group("Tile colors")
@export var default_material: Material
@export var warning_material: Material
@export var good_material: Material
@export var bad_material: Material

@onready var mesh: MeshInstance3D = $Tile

var state: TileState:
	get:
		return _state
	set(value):
		_state = value
		match value:
			TileState.DEFAULT:
				mesh.material_override = default_material
			TileState.WARNING:
				mesh.material_override = warning_material
			TileState.GOOD:
				mesh.material_override = good_material
			TileState.BAD:
				mesh.material_override = bad_material


var _state: TileState = TileState.DEFAULT

func _on_area_3d_mouse_entered() -> void:
	mouse_over.emit(self)


func _on_area_3d_mouse_exited() -> void:
	mouse_leave.emit(self)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var clickEvent = event as InputEventMouseButton
		if clickEvent.button_index == MOUSE_BUTTON_LEFT and clickEvent.pressed:
			mouse_click.emit(self)