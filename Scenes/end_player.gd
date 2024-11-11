extends CharacterBody2D


const SPEED = 400.0



func _physics_process(delta: float) -> void:
	handleInput()
	move_and_slide()

func handleInput() -> void:
	var moveDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = moveDirection * SPEED
