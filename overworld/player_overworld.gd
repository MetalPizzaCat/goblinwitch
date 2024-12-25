extends CharacterBody3D
class_name PlayerOverworld


@export var speed: float = 5
@onready var body: CharacterBody = $Body
@onready var camera: Camera3D = $Camera3D2
@onready var narrator: Narrator = $Narrator
@onready var visuals_anim_player : AnimationPlayer = $Visuals/VisualAnimations

@export var character: Character

@export_group("Story flags")
@export var is_goblin : bool = true

var interaction_target : Node

func _physics_process(_delta: float) -> void:
	if narrator.active:
		update_animation()
		return

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
		

	update_animation()
	move_and_slide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and interaction_target != null and interaction_target.has_method("interact"):
		interaction_target.interact(self)

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


func _on_narrator_narration_over() -> void:
	narrator.visible = false
