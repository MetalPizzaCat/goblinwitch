extends Node

func request_level_sub_load(node_path: String) -> void:
	if not get_tree().current_scene is Overworld:
		printerr("Attempted to load sublevel but root node is not Overworld")
		return
	var sub = get_tree().current_scene.get_node(node_path)
	if sub == null or not sub is Sublevel:
		printerr("Unable to find sub level node : %s of type SubLevel" % node_path)
		return
	sub.is_loaded = true