extends Control

@onready var room = $"../../"

# Restart the scene when the restart button is pressed
func _on_restart_pressed() -> void:
	var room_scene_path = "res://Scenes/Room.tscn"  # Path to Room.tscn scene
	
	# Load and instantiate the new scene
	var new_scene = load(room_scene_path).instantiate()
	
	# Free the current scene and add the new one
	get_tree().current_scene.queue_free()  # Free the current scene
	get_tree().root.add_child(new_scene)   # Add the new scene to the root
	
	# Reset the time scale to 1 (resume game time)
	Engine.time_scale = 1

# Quit the game when the quit button is pressed
func _on_quit_pressed() -> void:
	get_tree().quit()
