extends Node3D

@export var area_size: int = 5
@export_group("Combat")
@export var combat_scenario: CombatScenario
@export_group("Cells")
@export var cell_prefab: PackedScene
@export var size_between_cells: float = 3.1

@onready var cell_root: Node3D = $CellRoot
@onready var selection_arrow: Node3D = $Arrow
@onready var player: Fighter = $Player

var cells: Array[CombatCell] = []

func _ready() -> void:
	generate_grid()
	load_combat_scenario(combat_scenario)

func load_combat_scenario(scenario: CombatScenario) -> void:
	combat_scenario = scenario
	if scenario == null:
		return

	var player_local_pos: Vector3 = get_cell_local_pos(scenario.player_position)
	player.position = Vector3(
		player_local_pos.x + cell_root.position.x,
		player.position.y,
		player_local_pos.z + cell_root.position.z,
	)

func generate_grid() -> void:
	if cell_prefab == null:
		printerr("Missing cell prefab!")
		return
	for x in range(area_size):
		for y in range(area_size):
			var cell = cell_prefab.instantiate() as CombatCell
			cell_root.add_child(cell)
			cell.position = Vector3(x * size_between_cells, 0, y * size_between_cells)
			cells.append(cell)
			cell.arena_position = Vector2i(x, y)
			cell.mouse_click.connect(_on_cell_clicked)
			cell.mouse_leave.connect(_on_cell_mouse_left)
			cell.mouse_over.connect(_on_cell_mouse_over)

func get_cell_local_pos(cell_pos: Vector2i) -> Vector3:
	for cell in cells:
		if cell.arena_position == cell_pos:
			return cell.position
	return Vector3.ZERO

func _on_cell_mouse_over(cell: CombatCell) -> void:
	selection_arrow.position = Vector3(cell.position.x + cell_root.position.x, selection_arrow.position.y, cell.position.z + cell_root.position.z)

func _on_cell_mouse_left(cell: CombatCell) -> void:
	pass

func _on_cell_clicked(cell: CombatCell) -> void:
	pass