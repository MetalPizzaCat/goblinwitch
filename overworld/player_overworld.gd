extends CharacterBody3D
class_name PlayerOverworld

signal inventory_updated
signal item_consumed(consumable: Item)

@export var speed: float = 5
@onready var camera: Camera3D = $Camera3D2
@onready var narrator: Narrator = $Narrator
@onready var visuals_anim_player: AnimationPlayer = $Visuals/VisualAnimations
@onready var inventory: Inventory = $Inventory

@onready var new_item_name_label: RichTextLabel = $Visuals/Panel/VBoxContainer/RichTextLabel
@onready var cheat_console: CheatConsole = $CheatConsole

@onready var human_body: CharacterBody = $human_boy
@onready var goblin_body: CharacterBody = $goblin_girl

@onready var failure_screen: Control = $FailureScreen

@export var character: Character
@export var human_fighter_body_scene: PackedScene
@export var goblin_fighter_body_scene: PackedScene

@export var is_in_credits: bool = false
var is_in_combat: bool = false

@export_group("Story flags")
@export var is_goblin: bool:
	get:
		return _is_goblin
	set(value):
		_is_goblin = value
		
		if human_body == null or goblin_body == null:
			return
		human_body.visible = not value
		goblin_body.visible = value
		character.model_prefab = human_fighter_body_scene if not value else goblin_fighter_body_scene


var cutscene_paused: bool:
	get:
		return _cutscene_paused
	set(value):
		_cutscene_paused = value
		human_body.animation_paused = value
		goblin_body.animation_paused = value
		cheat_console.visible = cheat_console.visible and value

var _cutscene_paused: bool = false
var _is_goblin: bool = true

var interaction_target: Node

var body: CharacterBody:
	get:
		return goblin_body if is_goblin else human_body


var dead: bool = false

func _ready() -> void:
	is_goblin = is_goblin


func _physics_process(_delta: float) -> void:
	## prevent ALL updates to simulate being stuck
	if cutscene_paused or dead:
		return
	if narrator.active:
		update_animation()
		return

	if Input.is_action_just_pressed("inventory") and not is_in_credits:
		if inventory.active:
			inventory.hide_inventory()
		else:
			inventory.show_inventory()
	if Input.is_action_just_pressed("cheat") and not is_in_credits:
		cheat_console.visible = not cheat_console.visible

	if Input.is_action_just_pressed("interact") and interaction_target != null and interaction_target.has_method("interact"):
		interaction_target.interact(self)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_right", "move_left", "move_backward", "move_forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and not is_in_combat:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		body.look_at(global_position + direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if Input.is_action_just_pressed("cutscene_test"):
		cutscene_paused = true
		return

	update_animation()
	move_and_slide()

func play_narration(narration: Narration) -> void:
	narrator.visible = true
	narrator.set_narration(narration)

func fade_in() -> void:
	visuals_anim_player.play("fade_in")

func fade_out() -> void:
	pass

func update_animation() -> void:
	if velocity:
		body.play_animation("run")
	else:
		body.play_animation("idle")

func receive_item(item: Item) -> void:
	if item == null or (item.is_weapon and character.items.any(func(p): return p == item)):
		return
	character.items.append(item)
	print("Got %s" % item.name)
	new_item_name_label.text = '[center][wave][rainbow]%s[/rainbow][/wave][/center]' % item.name
	visuals_anim_player.play("got_item")
	if inventory.active:
		inventory.create_inventory()
	

func remove_item(item: Item) -> void:
	character.items.erase(item)
	if inventory.active:
		inventory.hide_inventory()

func _on_narrator_narration_over() -> void:
	narrator.visible = false


func _on_inventory_item_changed() -> void:
	inventory_updated.emit()
	print("item updated")


func _on_inventory_used_consumable(consumable: Item) -> void:
	item_consumed.emit(consumable)

func get_save_data() -> Dictionary:
	return {"pos": position, "data": character.get_player_save_data(), "trans": is_goblin}

func load_save_data(data: Dictionary) -> void:
	global_position = data['pos']
	is_goblin = data['trans']
	character.load_data(data['data'])


func _on_cheat_console_item_added(item: Item) -> void:
	receive_item(item)

func show_failure_screen(fast: bool = true) -> void:
	visuals_anim_player.play("failure_fast" if fast else "failure")


## Play death animation and show death sequence 
func die() -> void:
	# lol rip bozo
	body.play_animation("die")
	dead = true
	await body.animation_player.animation_finished
	show_failure_screen(false)

func _on_load_button_pressed() -> void:
	get_node("/root/SaveManager").load_game()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_save_button_pressed() -> void:
	get_node("/root/SaveManager").save_game()
