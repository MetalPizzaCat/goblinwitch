extends CharacterBody3D
class_name PlayerOverworld


@export var speed: float = 5
@onready var body: CharacterBody = $Body
@onready var camera : Camera3D = $Camera3D2

@export var character : Character

func _physics_process(_delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
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


func update_animation() -> void:
	if velocity:
		body.play_animation("run")
	else:
		body.play_animation("idle")
