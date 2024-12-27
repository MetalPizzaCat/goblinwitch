extends Fighter
class_name Player

enum PlayerSelection {NONE, MOVING, ATTACK}

var selected_attack: Attack
var player_selection: PlayerSelection = PlayerSelection.NONE

func on_tile_selected(tile: CombatCell) -> void:
    match player_selection:
        PlayerSelection.MOVING:
            if tile.arena_position.distance_to(arena_position) <= 1:
                move_to_tile(tile.arena_position)
                use_ap(1)
        PlayerSelection.ATTACK:
            if tile.arena_position.distance_to(arena_position) <= 1:
                var target = combat_arena.get_enemy_at(tile.arena_position)
                if target != null:
                    attack(target, selected_attack)
            else:
                print("Distance from %s to %s is %s" % [tile.arena_position, arena_position, tile.arena_position.distance_to(arena_position)])

func update_weapon() -> void:
    anim_body.set_used_weapon_type(WeaponDisplay.WeaponModel.NONE if character.weapon == null else character.weapon.model)