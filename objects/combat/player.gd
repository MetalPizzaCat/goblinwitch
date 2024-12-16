extends Fighter
class_name Player

func on_tile_selected(tile : CombatCell) -> void:
    # for now assume that every click is movement request
    move_to_tile(tile.arena_position)