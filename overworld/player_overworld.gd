extends CharacterBody3D
class_name PlayerOverworld

signal inventory_updated
signal item_consumed(consumable : Item)

@export var speed: float = 5
@onready var camera: Camera3D = $Camera3D2
@onready var narrator: Narrator = $Narrator
@onready var visuals_anim_player: AnimationPlayer = $Visuals/VisualAnimations
@onready var inventory: Inventory = $Inventory

@onready var new_item_name_label : RichTextLabel = $Visuals/Panel/VBoxContainer/RichTextLabel

@onready var human_body: CharacterBody = $human_boy
@onready var goblin_body: CharacterBody = $goblin_girl

@export var character: Character

@export_group("Story flags")
@export var is_goblin: bool = true


var cutscene_paused : bool:
	get:
		return _cutscene_paused
	set(value):
		_cutscene_paused = value
		human_body.animation_paused = value
		goblin_body.animation_paused = value

var _cutscene_paused : bool = false

var interaction_target: Node

var body: CharacterBody:
	get:
		return goblin_body if is_goblin else human_body

func _physics_process(_delta: float) -> void:
	## prevent ALL updates to simulate being stuck
	if cutscene_paused:
		if Input.is_action_just_pressed("cutscene_test") and false:
			cutscene_paused = false
		return
	if narrator.active:
		update_animation()
		return

	if Input.is_action_just_pressed("inventory"):
		if inventory.active:
			inventory.hide_inventory()
		else:
			inventory.show_inventory()
	if Input.is_action_just_pressed("interact") and interaction_target != null and interaction_target.has_method("interact"):
		interaction_target.interact(self)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_right", "move_left", "move_backward", "move_forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
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

func receive_item(item : Item) -> void:
	if item == null or (item.is_weapon and character.items.any(func (p) : return p == item)):
		return
	character.items.append(item)
	print("Got %s" % item.name)
	new_item_name_label.text = '[center][wave][rainbow]%s[/rainbow][/wave][/center]' % item.name
	visuals_anim_player.play("got_item")
	if inventory.active:
		inventory.create_inventory()
	

func remove_item(item : Item) -> void:
	character.items.erase(item)
	if inventory.active:
		inventory.hide_inventory()

func _on_narrator_narration_over() -> void:
	narrator.visible = false


func _on_inventory_item_changed() -> void:
	inventory_updated.emit()
	print("item updated")


func _on_inventory_used_consumable(consumable:Item) -> void:
	item_consumed.emit(consumable)
