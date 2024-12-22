extends Node3D
class_name Overworld

@export var combat_arena: CombatArena
@export var player: PlayerOverworld

@onready var combat_arena_storage: Node3D = $CombatArenaStorage

var is_in_combat: bool = false:
	get:
		return _is_in_combat
	set(value):
		_is_in_combat = value
		player.visible = not value
		player.camera.current = not value
		combat_arena.camera.current = value

var _is_in_combat: bool

func _ready() -> void:
	var combat_areas = get_tree().get_nodes_in_group("combat_area")
	for area in combat_areas:
		area.combat_triggered.connect(_on_combat_triggered)
	

func start_combat(combat_scenario: CombatScenario, combat_pos: Vector3) -> void:
	combat_arena.position = combat_pos
	combat_arena.load_combat_scenario(combat_scenario)
	is_in_combat = true
	combat_arena.start_combat(player.global_position, player.character)
	combat_arena.visible = true


func _on_combat_triggered(combat: CombatTrigger) -> void:
	start_combat(combat.scenario, to_local(combat.combat_spawn_position.global_position))


func _on_combat_arena_combat_ended() -> void:
	is_in_combat = false
	player.global_position = combat_arena.player.global_position
	combat_arena.visible = false
	combat_arena.position = combat_arena_storage.position
