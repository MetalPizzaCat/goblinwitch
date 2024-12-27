extends Node3D
class_name CombatArena

signal combat_ended
signal end_sequence_finished

@export var area_size: int = 5
@export_group("Combat")
@export var combat_scenario: CombatScenario

@export var fighter_movement_speed: float = 3
@export_group("Cells")
@export var cell_prefab: PackedScene
@export var size_between_cells: float = 3.1

@export_group("Overworld")
@export var overworld_player: PlayerOverworld

@onready var cell_root: Node3D = $CellRoot
@onready var selection_arrow: Node3D = $Arrow
@onready var player: Player = $Player
@onready var camera: Camera3D = $Camera3D
@onready var combat_ui: CombatInterface = $CombatUi
@onready var fighter_manager: FighterManager = $FighterManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow: ArrowAnim = $AnimatedArrow

var cells: Array[CombatCell] = []

var arena_rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	player.combat_arena = self
	generate_grid()
	load_combat_scenario(combat_scenario)
	overworld_player.inventory_updated.connect(_on_player_inventory_updated)


## Load new combat scenario placing combat pawns in the right places [br]
## If scenario is null board just gets reset
func load_combat_scenario(scenario: CombatScenario) -> void:
	# remove old enemies just in case
	combat_ui.clear_character_cards()
	fighter_manager.clear_enemies()

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
		var enemy = fighter_manager.create_enemy(actor)
		# some additional events that don't need to be handled by turn manager
		enemy.arrow_effect_requested.connect(_on_arrow_effect_requested)


## Start combat and play player entering sequence
func start_combat(player_world_pos: Vector3, player_data: Character) -> void:
	player.global_position = player_world_pos
	player.character = player_data
	player.move_to_tile(find_closest_tile(cell_root.to_local(player_world_pos)))
	combat_ui.load_player_actions(player_data)
	combat_ui.set_player_current_ap(player.total_ap)
	combat_ui.create_character_card(player)
	combat_ui.visible = true
	combat_ui.start_combat()
	animation_player.play("start")
	

## Generate grid used for combat
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


## Get position of the cell by cell id relative to `cell_root` 
func get_cell_local_pos(cell_pos: Vector2i) -> Vector3:
	for cell in cells:
		if cell.arena_position == cell_pos:
			return cell.position
	return Vector3.ZERO


## Get position of the cell by cell id relative to the combat arena root
func tile_to_position(tile: Vector2i) -> Vector3:
	for cell in cells:
		if cell.arena_position == tile:
			return cell.position + cell_root.position
	return Vector3.ZERO

## Find tile closest to the position [br]
## `src` must be a local position relative to the combat arena root
func find_closest_tile(src: Vector3) -> Vector2i:
	return cells.reduce(
			func(max: CombatCell, curr: CombatCell): return curr if curr.position.distance_squared_to(src) < max.position.distance_squared_to(src) else max
		).arena_position


## Get enemy that is currently occupying this cell or null if cell is empty
func get_enemy_at(cell: Vector2i) -> Fighter:
	for enemy in fighter_manager.enemies:
		if enemy.arena_position == cell:
			return enemy
	return null


func is_valid_position(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.y < 0 or pos.x >= area_size or pos.y >= area_size:
		return false
	if fighter_manager.enemies.any(func(p: Enemy): return p.arena_position == pos):
		return false
	return true


func end_combat(player_won: bool) -> void:
	overworld_player.global_position = player.global_position
	print("Combat should end")
	animation_player.play("end")
	combat_ui.end_combat(player_won)
	combat_ended.emit()
	

func clear_tile_states() -> void:
	for cell in cells:
		cell.state = CombatCell.TileState.DEFAULT

func _on_cell_mouse_over(cell: CombatCell) -> void:
	selection_arrow.position = Vector3(cell.position.x + cell_root.position.x, selection_arrow.position.y, cell.position.z + cell_root.position.z)


func _on_cell_mouse_left(cell: CombatCell) -> void:
	pass


func _on_cell_clicked(cell: CombatCell) -> void:
	if fighter_manager.is_player_turn and player.current_state == Fighter.ActionState.IDLE:
		player.on_tile_selected(cell)


func _on_combat_ui_player_action_selected(action: Attack) -> void:
	player.player_selection = Player.PlayerSelection.ATTACK
	player.selected_attack = action
	for cell in cells:
		var dist = cell.arena_position.distance_to(player.arena_position)
		if dist <= action.attack_range:
			match action.attack_type:
				Attack.AttackType.MELEE:
					cell.state = CombatCell.TileState.GOOD if dist <= 1 else CombatCell.TileState.WARNING
				Attack.AttackType.RANGED:
					cell.state = CombatCell.TileState.GOOD if dist > 1 else CombatCell.TileState.WARNING
		else:
			cell.state = CombatCell.TileState.DEFAULT
	

func _on_combat_ui_player_move_selected() -> void:
	player.player_selection = Player.PlayerSelection.MOVING
	for cell in cells:
		cell.state = CombatCell.TileState.DEFAULT if cell.arena_position.distance_to(player.arena_position) > 1 else CombatCell.TileState.GOOD


func _on_fighter_manager_all_enemies_died() -> void:
	end_combat(true)

func _on_fighter_manager_player_died() -> void:
	end_combat(false)


func _on_player_used_action_points(_amount: int) -> void:
	combat_ui.set_player_current_ap(player.current_ap)
	#combat_ui.unselect_all_buttons()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "end":
		end_sequence_finished.emit()


func _on_combat_ui_player_action_unselected() -> void:
	player.player_selection = Player.PlayerSelection.NONE
	player.selected_attack = null
	for cell in cells:
		cell.state = CombatCell.TileState.DEFAULT


func _on_player_inventory_updated() -> void:
	print("player inventory updated")
	combat_ui.load_player_actions(player.character)
	player.update_weapon()


func _on_arrow_effect_requested(from: Fighter, to: Fighter) -> void:
	arrow.move(from.position, to.position)
	arrow.visible = true
	arrow.look_at(Vector3(to.global_position.x, arrow.global_position.y, to.global_position.z))

func _on_animated_arrow_finished() -> void:
	arrow.visible = false
