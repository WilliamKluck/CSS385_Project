extends CharacterBody2D


const SPEED = 400.0
var direction = null
var active = false

func _physics_process(delta: float) -> void:
	if direction:
		velocity = direction * SPEED
	if active and (global_position.x < 0 or global_position.x > 1300 or global_position.y < 0 or global_position.y > 800):
		active = false
		#print("switched to false")
	move_and_slide()
