extends Button
class_name ActionButton

signal action_toggled(action : Attack, state : bool)
@export var attack_action : Attack:
    get:
        return _action
    set(value):
        _action = value
        text = value.name

var _action : Attack

func _ready() -> void:
    toggle_mode = true
    toggled.connect(_toggled)

func _toggled(state : bool) -> void:
    action_toggled.emit(attack_action, state)