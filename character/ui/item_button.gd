extends Button
class_name InventoryItemButton

signal item_clicked(item: Item)
signal item_selected(item: Item)
signal item_unselected(item: Item)

@export var item: Item
var selected: bool:
	get:
		return _selected
	set(value):
		_selected = value
		text = "* %s *" % item.name if selected else item.name

var _selected: bool = false

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_over)
	mouse_exited.connect(_on_mouse_leave)
	text = item.name


func _on_mouse_over() -> void:
	item_selected.emit(item)


func _on_mouse_leave() -> void:
	item_unselected.emit(item)


func _on_pressed() -> void:
	item_clicked.emit(item)
