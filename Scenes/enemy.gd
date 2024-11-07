extends CharacterBody2D


const SPEED = 300.0


func _physics_process(delta: float) -> void:
	move_and_slide()


func _on_projectile_detector_body_entered(body: Node2D) -> void:
	print(body)
	if body.to_string().begins_with("Projectile"):
		body.visible = false
		body.set_global_position(Vector2(-10,-10))
		body.active = false
		body.direction = null
		print("enemy hit")
