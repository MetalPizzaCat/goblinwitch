extends Area3D
class_name CombatTrigger

signal combat_triggered(area : CombatTrigger)

@export var scenario : CombatScenario
@export var combat_spawn_position : Node3D
@export var active : bool = true


func _on_trigger_body_entered(body:Node3D) -> void:
	if body is PlayerOverworld:
		combat_triggered.emit(self)
		active = false

