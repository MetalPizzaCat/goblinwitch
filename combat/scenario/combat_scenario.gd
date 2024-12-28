extends Resource
class_name CombatScenario

@export var actors: Array[CombatScenarioActor] = []
@export var player_position: Vector2i = Vector2i.ZERO
@export_range(3, 6) var arena_size: int = 6