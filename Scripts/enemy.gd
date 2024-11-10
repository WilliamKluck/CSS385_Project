extends CharacterBody2D


const SPEED = 100.0
const jitter_angle = 25
const jitter_duration = 5	# frames
var hp = 100
var room_node = null
var player_node = null
var frame: int = -1

func _ready():
	room_node = get_node("../..")
	player_node = get_node("../../Player")

func _physics_process(_delta: float) -> void:
	frame += 1
	if room_node.begin:
		move()
		jitter((frame / jitter_duration) % 2)
		move_and_slide()

func move() -> void:
	var direction = (player_node.get_global_position() - get_global_position()).normalized()
	velocity = direction * SPEED
	
func jitter(flag):
	#print(jitter_angle if flag else -jitter_angle)
	velocity = velocity.rotated(deg_to_rad(jitter_angle if flag else -jitter_angle))
	#print(name)
	
func _on_projectile_detector_body_entered(body: Node2D) -> void:
	if body.to_string().begins_with("Projectile"):
		body.set_global_position(Vector2(-10,-10))
		body.active = false
		body.direction = null
		hp -= 25
		
		if hp <= 0:
			queue_free()
