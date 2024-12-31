extends Node3D
class_name CharacterBody
signal action_animation_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon_model_display : WeaponDisplay = $Armature/Skeleton3D/Weapon

@export var footstep_player_prefab : PackedScene

var footstep_player : FootstepPlayer

var animation_paused: bool:
	get:
		return _animation_paused
	set(value):
		_animation_paused = value
		if value:
			print("paused")
			animation_player.pause()
			footstep_player.active = false
		else:
			print_rich("[shake]unpaused[/shake]")
			animation_player.play()
			footstep_player.active = animation_player.current_animation == "run"

var _animation_paused : bool = false

func set_used_weapon_type(weapon_type : WeaponDisplay.WeaponModel) -> void:
	weapon_model_display.model = weapon_type

func play_animation(anim: String) -> void:
	animation_player.play(anim)
	if footstep_player != null:
		footstep_player.active = anim == "run"


func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)
	if footstep_player_prefab != null:
		footstep_player = footstep_player_prefab.instantiate() as FootstepPlayer
		add_child(footstep_player)

func _enable_body_parts(parts: Array[Node3D], enabled: bool) -> void:
	for part in parts:
		part.visible = enabled
	
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	action_animation_finished.emit()
