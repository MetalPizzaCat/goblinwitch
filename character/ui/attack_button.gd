extends Button
class_name InventoryAttackButton

signal attack_clicked(attack : Attack)
signal attack_selected(attack : Attack)
signal attack_unselected(attack : Attack)

@export var attack : Attack

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_over)
	mouse_exited.connect(_on_mouse_leave)


func _on_mouse_over() -> void:
	attack_selected.emit(attack)


func _on_mouse_leave() -> void:
	attack_unselected.emit(attack)


func _on_pressed() -> void:
	attack_clicked.emit(attack)
