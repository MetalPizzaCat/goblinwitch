extends Fighter
class_name Enemy

@export var target: Fighter
@export var active: bool = false

func _ready() -> void:
	action_completed.connect(_on_action_finished)

func run_ai_logic() -> void:
	if is_dead:
		# just in case
		return
	if health < character.get_max_health() * 0.3:
		# heal yourself, but we can't heal yet
		pass
	var dist = target.arena_position.distance_to(arena_position)
	var melee_attacks = generate_list_of_possible_attacks(Attack.AttackType.MELEE)
	var ranged_attacks = generate_list_of_possible_attacks(Attack.AttackType.RANGED)
	

	print("Melee: %s; Ranged: %s; Dist: %s; Points: %s" % [len(melee_attacks), len(ranged_attacks), dist, current_ap])
	# can attack melee 
	if dist <= 1 and not melee_attacks.is_empty():
		print("Punching!")
		attack(target, melee_attacks.pick_random())
	# can attack ranged
	elif dist <= 3 and not ranged_attacks.is_empty():
		attack(target, ranged_attacks.pick_random())
	# can attack ranged but too close for it to be effective
	elif dist < 1 and not ranged_attacks.is_empty():
		move_to_tile(find_suitable_tile(func(a, b): return a > b))
		use_ap(1)
	# can attack melee but can't reach
	elif dist > 1 and not melee_attacks.is_empty():
		move_to_tile(find_suitable_tile(func(a, b): return a < b))
		use_ap(1)
	else:
		printerr("Enemy doesn't know what to do")
	

func generate_list_of_possible_attacks(attack_type: Attack.AttackType) -> Array[Attack]:
	var attacks: Array[Attack] = []
	for atk in get_weapon_attacks():
		if atk.attack_type == attack_type and atk.ap_cost <= current_ap:
			attacks.append(atk)
	for spell in character.spells:
		if (spell.attack_type == attack_type
			and spell.ap_cost <= current_ap
			and spell.mana_cost <= current_mana # spells use additional resource
			and combat_arena.arena_rng.randf() > 0.5 # to prevent ai from using too many spells
		):
			attacks.append(spell)
	return attacks
	
func find_suitable_tile(comp: Callable) -> Vector2i:
	var movement_ops: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
	var curr: Vector2i = arena_position
	var best_fit: float = target.arena_position.distance_to(curr)
	for op in movement_ops:
		var pos = arena_position + op
		print("Considering tile %s -> %s; valid = %s " % [pos, target.arena_position.distance_to(pos), combat_arena.is_valid_position(pos)])
		if comp.call(target.arena_position.distance_to(pos), best_fit) and combat_arena.is_valid_position(pos):
			curr = pos
			best_fit = target.arena_position.distance_to(pos)
	return curr


func _on_action_finished() -> void:
	print('action not reaction')
	if current_ap > 0 and active and not is_dead:
		run_ai_logic()
