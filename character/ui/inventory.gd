extends Control
class_name Inventory

signal item_changed
signal used_consumable(consumable: Item)

@export var player: PlayerOverworld

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var item_container: VBoxContainer = $Panel/ItemContainer
@onready var spell_container: VBoxContainer = $Panel/SpellContainer
@onready var potions_container: VBoxContainer = $Panel/ConsumableContainer

@onready var item_name_label: Label = $InfoPanel/ItemInfo/ItemNameLabel
@onready var item_desc_label: Label = $InfoPanel/ItemInfo/ItemDescLabel
@onready var stats_box: HBoxContainer = $InfoPanel/ItemInfo/Stats
@onready var item_damage_label: Label = $InfoPanel/ItemInfo/Stats/DamageVal

@onready var attack_info_container: VBoxContainer = $InfoPanel/ItemInfo/AttackInfoContainer

var active: bool = false

var item_buttons: Array[InventoryItemButton] = []
var potion_buttons: Array[InventoryItemButton] = []
var spell_buttons: Array[InventoryAttackButton] = []

func show_inventory() -> void:
	create_inventory()
	animation_player.play("show")
	active = true

func create_inventory() -> void:
	for item in item_buttons:
		item_container.remove_child(item)
		item.queue_free()
	item_buttons.clear()

	for potion in potion_buttons:
		potions_container.remove_child(potion)
		potion.queue_free()
	potion_buttons.clear()

	for spell in spell_buttons:
		spell_container.remove_child(spell)
		spell.queue_free()
	spell_buttons.clear()

	for item in player.character.items:
		var btn = InventoryItemButton.new()
		btn.item = item
		if item.is_weapon:
			item_buttons.append(btn)
			item_container.add_child(btn)
		else:
			potion_buttons.append(btn)
			potions_container.add_child(btn)
		btn.item_selected.connect(_on_item_selected)
		btn.item_unselected.connect(_on_item_unselected)
		btn.item_clicked.connect(_on_item_pressed)
		if item == player.character.weapon:
			btn.selected = true
			
	for spell in player.character.spells:
		var btn = InventoryAttackButton.new()
		btn.attack = spell
		btn.attack_selected.connect(_on_spell_selected)
		spell_buttons.append(btn)
		spell_container.add_child(btn)

func hide_inventory() -> void:
	animation_player.play_backwards("show")
	active = false

func _on_item_pressed(item: Item) -> void:
	if item.is_weapon:
		player.character.weapon = item
		for btn in item_buttons:
			btn.selected = btn.item == item
		print("changed item to %s" % item.name)
		item_changed.emit()
	else:
		used_consumable.emit(item)
	
	
func _on_item_selected(item: Item) -> void:
	show_item(item)

func _on_item_unselected(item: Item) -> void:
	pass


func _on_spell_pressed(spell: Attack) -> void:
	pass

func _on_spell_selected(spell: Attack) -> void:
	show_spell(spell)

func _on_spell_unselected(spell: Attack) -> void:
	pass

func _clear_attack_info() -> void:
	var attack_infos: Array[Node] = attack_info_container.get_children()
	for info in attack_infos:
		attack_info_container.remove_child(info)
		info.queue_free()

func _add_attack_info(attack: Attack) -> void:
	var hbox = HBoxContainer.new()
	attack_info_container.add_child(hbox)
	var text = Label.new()
	var value = Label.new()
	text.text = "%s :" % attack.name
	value.text = str(player.character.get_melee_damage() * attack.damage_modifier)
	hbox.add_child(text)
	hbox.add_child(value)
	

func show_item(item: Item) -> void:
	item_name_label.text = item.name
	item_desc_label.text = item.description
	stats_box.visible = item.is_weapon
	attack_info_container.visible = item.is_weapon
	_clear_attack_info()
	for attack in item.attacks:
		_add_attack_info(attack)

func show_spell(spell: Attack) -> void:
	item_name_label.text = spell.name
	item_desc_label.text = spell.description
	stats_box.visible = false

func _on_spells_pressed() -> void:
	item_container.visible = false
	spell_container.visible = true
	potions_container.visible = false

func _on_items_pressed() -> void:
	item_container.visible = true
	spell_container.visible = false
	potions_container.visible = false


func _on_consumable_pressed() -> void:
	item_container.visible = false
	spell_container.visible = false
	potions_container.visible = true
