extends Control
class_name Narrator

signal narration_over

@export var current_narration: Narration
@export var target_display_rate: float = 0.05

var target_display_time: float = 0
var active: bool = false

var target_char_update_time : float = 0
var current_time: float = 0

@onready var text_label: RichTextLabel = $Panel/Dialog
@onready var prompt_label: RichTextLabel = $Panel/Prompt
@onready var character_advance_sound: AudioStreamPlayer = $DialogSound


var narration_id: int:
	get:
		return _narration_id
	set(value):
		_narration_id = value
		if current_narration != null and value < len(current_narration.lines):
			text_label.text = current_narration.lines[narration_id].text
			text_label.visible_ratio = 0
			target_display_time = target_display_rate * len(current_narration.lines[narration_id].text) * current_narration.lines[narration_id].speed_modifier
			target_char_update_time = target_display_rate * current_narration.lines[narration_id].speed_modifier

var _narration_id: int = -1

var current_display_time: float = 0

func _ready() -> void:
	set_narration(current_narration)


func _input(_event: InputEvent) -> void:
	if current_display_time > (target_display_time * 0.75) and Input.is_action_just_pressed("interact"):
		narration_id += 1
		current_display_time = 0
		if narration_id >= len(current_narration.lines):
			active = false
			narration_over.emit()
			current_narration = null
			

func set_narration(narration: Narration) -> void:
	current_narration = narration
	active = narration != null
	narration_id = 0
	

func _process(delta: float) -> void:
	if current_narration != null:
		current_display_time += delta
		current_time += delta
		if current_time > target_char_update_time and text_label.visible_ratio < 1:
			character_advance_sound.play()
			current_time = 0
		text_label.visible_ratio = current_display_time / target_display_time
		prompt_label.visible = current_display_time > (target_display_time * 0.75)