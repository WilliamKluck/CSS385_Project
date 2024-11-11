extends Control

@onready var room = $"../../"

func _on_restart_pressed() -> void:
	var room_scene_path = "res://Scenes/Room.tscn"  # Path to Room.tscn scene
	var base = get_tree().root
	for child in base.get_children():
		base.remove_child(child)
		child.queue_free()
	# Load the new scene and instance it
	var new_scene = load(room_scene_path).instantiate()
	# Add the new scene to the root node
	base.add_child(new_scene)
	Engine.time_scale = 1
	return
	
func _on_quit_pressed() -> void:
	get_tree().quit()
