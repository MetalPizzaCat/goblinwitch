extends Control
class_name CombatInterface

signal player_move_selected
signal player_action_selected(action : Attack)

@onready var attacks_box: HBoxContainer = $Panel/Actions/Attacks
@export var action_button_group: ButtonGroup

var player_action_buttons : Array[ActionButton] = []

func load_player_actions(player: Character) -> void:
	for attack in player.weapon.attacks:
		add_player_action(attack)
	for spell in player.spells:
		add_player_action(spell)


func add_player_action(action: Attack) -> void:
	var btn = ActionButton.new()
	attacks_box.add_child(btn)
	btn.attack_action = action
	btn.button_group = action_button_group
	btn.action_toggled.connect(_on_player_action_selected)
	player_action_buttons.append(btn)


func _on_player_action_selected(action: Attack, state: bool) -> void:
	if state:
		player_action_selected.emit(action)

func _on_move_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		player_move_selected.emit()
		
