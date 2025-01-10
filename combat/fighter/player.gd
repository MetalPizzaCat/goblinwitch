extends Fighter
class_name Player

enum PlayerSelection {NONE, MOVING, ATTACK}

signal player_took_action

var selected_attack: Attack
var player_selection: PlayerSelection = PlayerSelection.NONE

func on_tile_selected(tile: CombatCell) -> void:
	match player_selection:
		PlayerSelection.MOVING:
			if tile.arena_position.distance_to(arena_position) <= 1 and combat_arena.is_valid_position(tile.arena_position):
				move_to_tile(tile.arena_position)
				use_ap(1)
				player_took_action.emit()
		PlayerSelection.ATTACK:
			if tile.arena_position.distance_to(arena_position) <= selected_attack.attack_range:
				var target = combat_arena.get_enemy_at(tile.arena_position)
				if target != null and not target.is_dead:
					attack(target, selected_attack)
					player_took_action.emit()
			else:
				print("Distance from %s to %s is %s" % [tile.arena_position, arena_position, tile.arena_position.distance_to(arena_position)])

func update_weapon() -> void:
	if character == null or anim_body == null:
		return
	anim_body.set_used_weapon_type(WeaponDisplay.WeaponModel.NONE if character.weapon == null else character.weapon.model)
