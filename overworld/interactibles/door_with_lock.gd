extends Door

var interaction_counter : int
@export var key: Item

@export var interaction_text : Array[Narration] = []

func get_save_data() -> Dictionary:
	var base = super()
	base['count'] = interaction_counter
	return base

func load_save_data(data : Dictionary) -> void:
	super(data)
	interaction_counter = data['count']


func _on_interaction_body_entered(body: Node3D) -> void:
	if body is PlayerOverworld and not is_open:
		if body.character.items.any(func(p): return p == key):
			open()
		else:
			body.play_narration(interaction_text[interaction_counter])
			interaction_counter += 1
			interaction_counter = interaction_counter % interaction_text.size()