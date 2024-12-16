extends Node3D
class_name CombatArena

@export var area_size: int = 5
@export_group("Combat")
@export var combat_scenario: CombatScenario
@export var enemy_prefab : PackedScene
@export var fighter_movement_speed : float = 3
@export_group("Cells")
@export var cell_prefab: PackedScene
@export var size_between_cells: float = 3.1

@onready var cell_root: Node3D = $CellRoot
@onready var selection_arrow: Node3D = $Arrow
@onready var player: Player= $Player

var cells: Array[CombatCell] = []
var enemies : Array[Enemy] = []

func _ready() -> void:
	player.combat_arena = self
	generate_grid()
	load_combat_scenario(combat_scenario)


## Load new combat scenario placing combat pawns in the right places [br]
## If scenario is null board just gets reset
func load_combat_scenario(scenario: CombatScenario) -> void:
	# remove old enemies just in case
	for enemy in enemies:
		remove_child(enemy)
		enemy.queue_free()
	enemies.clear()

	combat_scenario = scenario
	if scenario == null:
		return

	var player_local_pos: Vector3 = get_cell_local_pos(scenario.player_position)
	player.position = Vector3(
		player_local_pos.x + cell_root.position.x,
		player.position.y,
		player_local_pos.z + cell_root.position.z,
	)

	for actor in combat_scenario.actors:
		var enemy = enemy_prefab.instantiate() as Enemy
		add_child(enemy)
		enemies.append(enemy)
		enemy.combat_arena = self
		enemy.target = player
		enemy.arena_position = actor.start_pos


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

func tile_to_position(tile : Vector2i) -> Vector3:
	for cell in cells:
		if cell.arena_position == tile:
			return cell.position + cell_root.position
	return Vector3.ZERO

func _on_cell_mouse_over(cell: CombatCell) -> void:
	selection_arrow.position = Vector3(cell.position.x + cell_root.position.x, selection_arrow.position.y, cell.position.z + cell_root.position.z)

func _on_cell_mouse_left(cell: CombatCell) -> void:
	pass

func _on_cell_clicked(cell: CombatCell) -> void:
	player.on_tile_selected(cell)