extends Control
class_name CombatInterface

signal player_move_selected
signal player_action_selected(action: Attack)
signal player_action_unselected

@onready var attacks_box: HBoxContainer = $Panel/Actions/Attacks
@onready var player_ap_panel: ActionPointPanel = $ActionPointPanel
@onready var fighter_card_box: HBoxContainer = $FighterCardBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var end_text_label: RichTextLabel = $VictoryLabel
@onready var move_button : Button = $Panel/Actions/MoveButton
@onready var victory_sound_player: AudioStreamPlayer = $VictorySoundPlayer
@onready var defeat_sound_player: AudioStreamPlayer = $DefeatSoundPlayer

@export var action_button_group: ButtonGroup
@export var fighter_card_prefab: PackedScene

@export var victory_text: String = '[wave][color=plum]VICTORY![/color][/wave]'
@export var defeat_text: String = '[color=red]defeat.[/color]'

var player_action_buttons: Array[ActionButton] = []
var cards: Array[CharacterInfo] = []

var move_button_state : bool

func unselect_all_buttons() -> void:
	move_button.button_pressed = false
	for btn in player_action_buttons:
		btn.button_pressed = false

func set_player_max_ap(ap: int) -> void:
	player_ap_panel.max_action_points = ap

func set_player_current_ap(ap: int) -> void:
	player_ap_panel.current_action_points = ap

func load_player_actions(player: Character) -> void:
	
	for act in player_action_buttons:
		attacks_box.remove_child(act)
		act.queue_free()
	player_action_buttons.clear()
	
	for attack in player.weapon.attacks:
		add_player_action(attack)
	for spell in player.spells:
		add_player_action(spell)

func clear_character_cards() -> void:
	for card in cards:
		fighter_card_box.remove_child(card)
		card.queue_free()
	cards.clear()

func create_character_card(fighter: Fighter) -> void:
	var card = fighter_card_prefab.instantiate() as CharacterInfo
	card.fighter = fighter
	fighter_card_box.add_child(card)
	cards.append(card)

func set_active_turn_character(fighter: Fighter) -> void:
	for ch in cards:
		ch.is_active = ch.fighter == fighter

func add_player_action(action: Attack) -> void:
	var btn = ActionButton.new()
	attacks_box.add_child(btn)
	btn.attack_action = action
	btn.button_group = action_button_group
	btn.action_toggled.connect(_on_player_action_selected)
	player_action_buttons.append(btn)

func start_combat() -> void:
	animation_player.play("start")

func end_combat(victory: bool) -> void:
	end_text_label.text = victory_text if victory else defeat_text
	if victory:
		victory_sound_player.play()
	else:
		defeat_sound_player.play()
	animation_player.play("end")

func _on_player_action_selected(action: Attack, state: bool) -> void:
	if state:
		player_action_selected.emit(action)
	else:
		player_action_unselected.emit()
	

func _on_move_button_toggled(toggled_on: bool) -> void:
	move_button_state = toggled_on
	
	if toggled_on:
		player_move_selected.emit()
	else:
		player_action_unselected.emit()
