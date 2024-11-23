extends CharacterBody2D

const jitter_angle = 25
const jitter_duration = 5	# frames
var SPEED = 100.0
var power = 1
var hp = 4
@onready var sprite = $AnimatedSprite2D
@onready var room_node = get_node("../..")
@onready var player_node = get_node("../../Player")
var frame: int = -1

func _ready():
	pass

func _physics_process(_delta: float) -> void:
	frame += 1
  
	# if scene begins, begin movement
	if room_node.begin == 1:
		move()
		jitter((frame / jitter_duration) % 2)
		move_and_slide()

func move() -> void:
	# move towards player
	var direction = (player_node.get_global_position() - get_global_position()).normalized()
	velocity = direction * SPEED
	
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
		
	
func jitter(flag):
	#print(jitter_angle if flag else -jitter_angle)
	velocity = velocity.rotated(deg_to_rad(jitter_angle if flag else -jitter_angle))
	#print(name)
	
func _on_projectile_detector_body_entered(body: Node2D) -> void:
	# if hit move projectile off screen, stop it and lose health
	if body.to_string().begins_with("Projectile"):
		body.set_global_position(Vector2(-100,-100))
		body.active = false
		body.direction = null
		hp -= body.power
		
		# if die, delete self
		if hp <= 0:
			queue_free()
