extends Control

@onready var room = $"../"

func _on_resume_pressed() -> void:
	room.pauseMenu()
	
func _on_quit_pressed() -> void:
	get_tree().quit()
