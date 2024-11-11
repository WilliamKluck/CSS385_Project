extends Control

@onready var on = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if on:
			on = false
			hide()
		else:
			on = true
			show()
