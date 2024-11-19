extends CharacterBody2D

const jitter_angle = 25
const jitter_duration = 5	# frames
var SPEED = 100.0
var power = 1
var hp = 4
var room_node = null
var player_node = null
var frame: int = -1

@onready var raycast = $RayCast2D
var last_player_seen_loc = null

func _ready():
	pass

func _physics_process(_delta: float) -> void:
	# get room node for checking scene beginning
	room_node = get_node("../..")
	# get player nodef for checking player position
	player_node = get_node("../../Player")
	frame += 1
  
	# if scene begins, begin movement
	if room_node.begin == 1:
		check_player_in_view()
		move()
		jitter((frame / jitter_duration) % 2)
		move_and_slide()
		
func check_player_in_view():
	var to_player = get_node("../../Player/Middle").get_global_position() - get_global_position()
	raycast.target_position = to_player
	#print(raycast.target_position)
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		#print(collider, frame)
		if collider == player_node:
			last_player_seen_loc = get_node("../../Player/Middle").get_global_position()

func move() -> void:
	# move towards last player seen loc
	if last_player_seen_loc:
		var direction = (last_player_seen_loc - get_global_position()).normalized()
		if (last_player_seen_loc - get_global_position()).length() < 10:
			velocity = Vector2.ZERO
		else:
			velocity = direction * SPEED
	
func jitter(flag):
	#print(jitter_angle if flag else -jitter_angle)
	velocity = velocity.rotated(deg_to_rad(jitter_angle if flag else -jitter_angle))
	#print(name)
	
func _on_projectile_detector_body_entered(body: Node2D) -> void:
	# if hit move projectile off screen, stop it and lose health
	if body.to_string().begins_with("Projectile"):
		body.set_global_position(Vector2(-10,-10))
		body.active = false
		body.direction = null
		hp -= body.power
		
		# if die, delete self
		if hp <= 0:
			queue_free()
