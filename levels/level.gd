extends Node3D
class_name Level

@export var level_name: String

func get_save_data() -> Dictionary:
	var level_objects = get_tree().get_nodes_in_group("%s_level" % level_name)
	var level_saved = get_tree().get_nodes_in_group("save").filter(func(p): return level_objects.find(p) != -1)
	return {"objects": level_saved.map(func(p): return {p.name: p.get_save_data()})}


func load_save_data(data: Dictionary) -> void:
	if 'objects' not in data:
		return
	for object in data['objects']:
		for key in object:
			var node = get_node_or_null(key)
			if node == null or not node.has_method('load_save_data'):
				printerr("Save data has info about %s but node doesn't exist" % key)
			else:
				node.load_save_data(object[key])
