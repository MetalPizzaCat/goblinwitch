extends WorldButton

@onready var model_anim : AnimationPlayer = $chest/AnimationPlayer
@onready var interaction_box : InteractionBox = $InteractionBox
@export var open : bool = false

## What item will this chest give once opened
@export var item : Item 

func _ready() -> void:
	if open:
		model_anim.play_backwards("move")
		model_anim.pause()
	model_anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(_name : String) -> void:
	pass

func interact(actor : PlayerOverworld) -> void:
	if not open:
		super(actor)
		actor.receive_item(item)
		model_anim.play("move")
		open = true
		interaction_box.turn_off()
