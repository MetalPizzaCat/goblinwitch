extends Control
class_name CheatConsole

signal item_added(item: Item)
signal spell_added(spell: Attack)

@onready var options: OptionButton = $HBoxContainer/OptionButton
@onready var res_path: TextEdit = $HBoxContainer/TextEdit

func _on_cheat_button_pressed() -> void:
	match options.selected:
		0: # item
			var res = ResourceLoader.load(res_path.text, "Item")
			if res == null:
				printerr("Failed to load %s" % res_path.text)
			else:
				item_added.emit(res)
		1: # spell
			pass
