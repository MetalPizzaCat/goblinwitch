extends WorldButton


@onready var interaction_box : InteractionBox = $InteractionBox
@onready var anim : AnimationPlayer = $AnimationPlayer


func interact(actor : PlayerOverworld) -> void:
	if not was_used:
		super(actor)
		anim.play("move")
		interaction_box.turn_off()



func load_save_data(data : Dictionary) -> void:
	super(data)
	if was_used:
		anim.play("start_moved")