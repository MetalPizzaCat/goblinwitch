extends WorldButton

@onready var model_anim: AnimationPlayer = $chest/AnimationPlayer
@onready var interaction_box: InteractionBox = $InteractionBox
@export var open: bool = false

## What item will this chest give once opened
@export var item: Item

func _ready() -> void:
	model_anim.play("idle_open" if open else "idle")
	model_anim.animation_finished.connect(_on_anim_finished)

func _on_anim_finished(_name: String) -> void:
	pass

func interact(actor: PlayerOverworld) -> void:
	if not open:
		super(actor)
		print("giving %s" % item.name)
		actor.receive_item(item)
		model_anim.play("move")
		open = true
		interaction_box.turn_off()


func get_save_data() -> Dictionary:
	return {"open" : open}


func load_save_data(data : Dictionary) -> void:
	open = data['open']
	model_anim.play("idle_open" if open else "idle")

