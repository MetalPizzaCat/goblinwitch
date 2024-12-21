extends Panel
class_name ActionPointPanel

@export var max_action_points: int = 3
@export var active_ap_texture: Texture
@export var inactive_ap_texture: Texture

@onready var box: HBoxContainer = $Actions

var current_action_points: int:
	get:
		return _current_action_points
	set(value):
		_current_action_points = min(max_action_points, value)
		for i in range(max_action_points):
			action_point_icons[i].texture = active_ap_texture if i < _current_action_points else inactive_ap_texture


var _current_action_points: int = 3

var action_point_icons: Array[TextureRect] = []

func _ready() -> void:
	for i in range(max_action_points):
		var icon = TextureRect.new()
		box.add_child(icon)
		action_point_icons.append(icon)
		icon.texture = active_ap_texture
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
