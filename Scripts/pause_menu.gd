extends Control



func _on_resume_pressed() -> void:
	var room = $"../.."
	room.toggle_pause_menu()  # Call the pauseMenu method in room.gd to resume the game

func _on_quit_pressed() -> void:
	get_tree().quit()  # Quit the game when the quit button is pressed
