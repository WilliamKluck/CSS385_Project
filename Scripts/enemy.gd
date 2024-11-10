extends CharacterBody2D

const SPEED = 100.0
var hp = 100
var room_node = null
var player_node = null

func _ready():
	pass

func _physics_process(_delta: float) -> void:
	# get room node for checking scene beginning
	room_node = get_node("../..")
	# get player nodef for checking player position
	player_node = get_node("../../Player")
	# if scene begins, begin movement
	if room_node.begin == 1:
		move()
		move_and_slide()

func move() -> void:
	# move towards player
	var direction = (player_node.get_global_position() - get_global_position()).normalized()
	velocity = direction * SPEED
	
func _on_projectile_detector_body_entered(body: Node2D) -> void:
	# if hit move projectile off screen, stop it and lose health
	if body.to_string().begins_with("Projectile"):
		body.set_global_position(Vector2(-10,-10))
		body.active = false
		body.direction = null
		hp -= 25
		
		# if die, delete self
		if hp <= 0:
			queue_free()
