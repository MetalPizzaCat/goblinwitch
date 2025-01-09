extends PanelContainer
class_name CharacterInfo

@export var active_style: StyleBoxFlat
@export var inactive_style: StyleBoxFlat

@export var fighter: Fighter

@export var is_active: bool = false:
	get:
		return _is_active
	set(value):
		_is_active = value
		add_theme_stylebox_override('panel', active_style if value else inactive_style)

var _is_active: bool

@onready var health_label: Label = $Label


func _ready() -> void:
	add_theme_stylebox_override('panel', active_style if is_active else inactive_style)
	if fighter:
		fighter.health_changed.connect(_on_health_changed)
		fighter.used_action_points.connect(_on_ap_point_used)
		_on_health_changed()

func _on_health_changed() -> void:
	health_label.text = "%s/%s" % [fighter.health, fighter.character.get_max_health()]
	print('health: %s ' % fighter.character.get_max_health())

func _on_ap_point_used(_ap_used : int) -> void:
	# idk do something with this later
	pass
