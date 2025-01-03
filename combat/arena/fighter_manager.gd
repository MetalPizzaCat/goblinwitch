extends Node
class_name FighterManager

signal player_died
signal all_enemies_died

@export var combat_ui: CombatInterface
@export var enemy_prefab: PackedScene

var _is_player_turn: bool = true
var is_player_turn: bool:
	get:
		return _is_player_turn
	set(value):
		_is_player_turn = value

@export var player: Player
@export var enemies: Array[Enemy] = []
@export var combat_arena: CombatArena

var waiting_for_animations_to_finish: bool = false

## Enemy that is currently using its turn
var current_enemy_id: int = 0

var current_enemy: Enemy:
	get:
		return null if current_enemy_id >= len(enemies) or current_enemy_id < 0 else enemies[current_enemy_id]

func _ready() -> void:
	player.used_all_action_points.connect(_on_player_finished_turn)
	player.died.connect(_on_player_died)
	player.action_completed.connect(_on_action_finished)

func clear_enemies() -> void:
	for enemy in enemies:
		combat_arena.remove_child(enemy)
		enemy.queue_free()
	enemies.clear()


func create_enemy(actor: CombatScenarioActor) -> Enemy:
	var enemy = enemy_prefab.instantiate() as Enemy
	combat_arena.add_child(enemy)
	enemies.append(enemy)
	enemy.character = actor.character
	enemy.combat_arena = combat_arena
	enemy.target = player
	enemy.arena_position = actor.start_pos
	enemy.used_all_action_points.connect(_on_enemy_finished_turn)
	enemy.action_completed.connect(_on_action_finished)
	enemy.died.connect(_on_enemy_died)
	combat_ui.create_character_card(enemy)
	return enemy

## Get next possible enemy in the enemy list [br]
## [param start] - what id in the enemy list to start from(inclusive) [br]
## return an id from the list or -1 if no suitable id was found 
func get_next_active_enemy_id(start: int = 0) -> int:
	print(enemies)
	for i in range(start, len(enemies)):
		print("%s is %s" % [enemies[i], enemies[i].is_dead])
		if not enemies[i].is_dead:
			return i
	return -1


## Reset player ap and start player turn
func start_player_turn() -> void:	
	current_enemy_id = -1
	if player.start_turn():
		await player.hurt_animation_finished
	is_player_turn = true
	combat_ui.set_active_turn_character(player)

## Start enemy turn and 
func start_enemy_turn() -> void:
	current_enemy.active = true
	if current_enemy.start_turn():
		# we should wait till all animations finish to not confuse ai
		await current_enemy.hurt_animation_finished
	# start of turn can apply effects which can cause enemy to die at the start of the turn
	# if this happens we don't run the logic
	# and this will also cause "end of turn" signal to be emited so we use that
	if not current_enemy.is_dead:
		combat_ui.set_active_turn_character(current_enemy)
		current_enemy.run_ai_logic()

## Move to the next fighter in the turn order. If player is current fighter it moves to the first enemy in the list.
## If it is an enemy it moves through the enemy list until there are no more enemies, which is when it switches to the player
func advance_turn() -> void:
	if is_player_turn:
		is_player_turn = false
		current_enemy_id = get_next_active_enemy_id()
		if current_enemy_id == -1:
			return
		start_enemy_turn()
	else:
		current_enemy.active = false
		current_enemy_id = get_next_active_enemy_id(current_enemy_id + 1)
		if current_enemy != null:
			start_enemy_turn()
		else:
			start_player_turn()

func _on_enemy_finished_turn() -> void:
	print("Enemy %s turn is over" % current_enemy_id)
	current_enemy.active = false
	waiting_for_animations_to_finish = true

func _on_player_finished_turn() -> void:
	print("Player turn is over")
	waiting_for_animations_to_finish = true
	

func _on_player_died() -> void:
	for enemy in enemies:
		enemy.active = false
		enemy.visible = false
	player_died.emit()


func _on_enemy_died() -> void:
	print("Someone died")
	if enemies.all(func(p): return p.is_dead):
		print("all enemies died")
		all_enemies_died.emit()

func _on_action_finished() -> void:
	if waiting_for_animations_to_finish and player.has_finished_all_actions and enemies.all(func(p: Enemy): return p.has_finished_all_actions):
		waiting_for_animations_to_finish = false
		advance_turn()
	elif waiting_for_animations_to_finish:
		print("Player finished: %s" % player.has_finished_all_actions)
		print(enemies.map(func(p: Enemy): return "%s finished: %s" % [p, p.has_finished_all_actions]))
