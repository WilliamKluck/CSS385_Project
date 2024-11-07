extends CharacterBody2D


const SPEED = 400.0
var direction = null
var active = false

func _physics_process(delta: float) -> void:
	if direction:
		velocity = direction * SPEED
	move_and_slide()
