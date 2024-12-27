extends Control
class_name Inventory

signal item_changed

@export var player : PlayerOverworld

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var item_container : VBoxContainer = $Panel/ItemContainer
@onready var spell_container : VBoxContainer = $Panel/SpellContainer

@onready var item_name_label : Label = $InfoPanel/ItemInfo/ItemNameLabel
@onready var item_desc_label : Label = $InfoPanel/ItemInfo/ItemDescLabel
@onready var item_damage_label : Label = $InfoPanel/ItemInfo/Stats/DamageVal

var active : bool = false

var item_buttons : Array[InventoryItemButton] = []
var spell_buttons : Array[InventoryAttackButton] = []

func show_inventory() -> void:
	for item in item_buttons:
		item_container.remove_child(item)
		item.queue_free()
	item_buttons.clear()

	for spell in spell_buttons:
		spell_container.remove_child(spell)
		spell.queue_free()
	spell_buttons.clear()

	for item in player.character.items:
		var btn = InventoryItemButton.new()
		btn.item = item
		item_buttons.append(btn)
		item_container.add_child(btn)
		btn.item_selected.connect(_on_item_selected)
		btn.item_unselected.connect(_on_item_unselected)
		btn.item_clicked.connect(_on_item_pressed)
		if item == player.character.weapon:
			btn.selected = true
	for spell in player.character.spells:
		pass
	animation_player.play("show")
	active = true

func hide_inventory() -> void:
	animation_player.play_backwards("show")
	active = false

func _on_item_pressed(item : Item) -> void:
	player.character.weapon = item
	for btn in item_buttons:
		btn.selected = btn.item == item
	print("changed item to %s" % item.name)
	item_changed.emit()
	
	

func _on_item_selected(item : Item) -> void:
	show_item(item)

func _on_item_unselected(item : Item) -> void:
	pass


func _on_spell_pressed(spell : Attack) -> void:
	pass

func _on_spell_selected(spell : Attack) -> void:
	pass

func _on_spell_unselected(spell : Attack) -> void:
	pass

func show_item(item : Item) -> void:
	item_name_label.text = item.name
	item_desc_label.text = item.description
	item_damage_label.text = str(item.damage)

func _on_spells_pressed() -> void:
	item_container.visible = false
	spell_container.visible = true

func _on_items_pressed() -> void:
	item_container.visible = true
	spell_container.visible = false
