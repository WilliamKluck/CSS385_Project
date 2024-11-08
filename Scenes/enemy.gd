extends CharacterBody2D


const SPEED = 100.0
var hp = 100


func _physics_process(delta: float) -> void:
	var player = get_node("../Player")
	#print(player)
	var direction = (player.get_global_position() - get_global_position()).normalized()
	velocity = direction * SPEED
	move_and_slide()


func _on_projectile_detector_body_entered(body: Node2D) -> void:
	#print("body entered")
	#print(body.name)
	if body.to_string().begins_with("Projectile"):
		print(hp)
		#body.visible = false
		body.set_global_position(Vector2(-10,-10))
		body.active = false
		body.direction = null
		hp -= 25
		
		if hp <= 0:
			# die
			print("die")
			queue_free()
		print("enemy hit")
