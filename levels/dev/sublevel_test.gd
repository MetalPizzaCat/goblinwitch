extends Node3D


@onready var lvl1 : Sublevel = $SubLevel
@onready var lvl2 : Sublevel = $SubLevel2


func _ready() -> void:
	var effects : Dictionary = {}
	effects[Attack.Effect.FIRE] = 1
	effects[Attack.Effect.POISON] = 3

	print(effects)
	for effect in effects.keys():
		effects[effect] -= 1
		if effects[effect] <= 0:
			effects.erase(effect)
	print(effects)

func _on_sublevel_1_load_2_body_exited(_body:Node3D) -> void:
	lvl2.unload_level()
	
func _on_sublevel_1_load_2_body_entered(_body:Node3D) -> void:
	lvl2.load_level()
	

func _on_sublevel_1_load_body_exited(_body:Node3D) -> void:
	lvl1.unload_level()

func _on_sublevel_1_load_body_entered(_body:Node3D) -> void:
	lvl1.load_level()
