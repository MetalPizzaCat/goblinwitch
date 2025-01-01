@tool
extends Node3D
class_name MockArena


@export_range(1, 7) var area_size: int:
	get:
		return _area_size
	set(value):
		_area_size = value
		if not Engine.is_editor_hint():
			return
		for cell in cells:
			cell_root.remove_child(cell)
			cell.queue_free()
		cells.clear()
		if is_showing:
			generate_grid()


@onready var cell_root: Node3D = $CellRoot

var cells: Array[CombatCell] = []

@export var is_showing: bool:
	get:
		return _is_showing
	set(value):
		if cell_prefab == null:
			_is_showing = false
			return
		if not Engine.is_editor_hint():
			return
		_is_showing = value
		if value:
			generate_grid()
		else:
			for cell in cells:
				cell_root.remove_child(cell)
				cell.queue_free()
			cells.clear()


@export_group("Cells")
@export var cell_prefab: PackedScene
@export var size_between_cells: float = 3.1

var _is_showing: bool = false
var _area_size : int = 6

## Generate grid used for combat
func generate_grid() -> void:
	if cell_prefab == null:
		printerr("Missing cell prefab!")
		return
	if cell_root == null:
		return	
	for x in range(area_size):
		for y in range(area_size):
			var cell = cell_prefab.instantiate() as CombatCell
			cell_root.add_child(cell)
			cell.position = Vector3(x * size_between_cells, 0, y * size_between_cells)
			cells.append(cell)
			cell.owner = get_tree().edited_scene_root
			cell.arena_position = Vector2i(x, y)