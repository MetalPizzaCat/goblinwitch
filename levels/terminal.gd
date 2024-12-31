extends VBoxContainer

@export var blip_sound_player : AudioStreamPlayer

func add_message(sender: String, message: String) -> void:
	var label = Label.new()
	label.text = "%s%s" % [sender, message]
	add_child(label)
	blip_sound_player.play()
