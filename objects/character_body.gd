extends Node3D
class_name CharacterBody
signal action_animation_finished

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon_model_display : WeaponDisplay = $Armature/Skeleton3D/Weapon

func set_used_weapon_type(weapon_type : WeaponDisplay.WeaponModel) -> void:
	weapon_model_display.model = weapon_type

func play_animation(anim: String) -> void:
	animation_player.play(anim)


func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(_on_animation_player_animation_finished)

func _enable_body_parts(parts: Array[Node3D], enabled: bool) -> void:
	for part in parts:
		part.visible = enabled
	
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	action_animation_finished.emit()
