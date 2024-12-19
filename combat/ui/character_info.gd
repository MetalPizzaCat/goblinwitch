extends PanelContainer
class_name CharacterInfo

@export var active_style: StyleBoxFlat
@export var inactive_style: StyleBoxFlat

@export var is_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_theme_stylebox_override('panel', active_style if is_active else inactive_style)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
