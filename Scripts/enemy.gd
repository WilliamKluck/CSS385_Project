extends CharacterBody2D

const jitter_angle = 25
const jitter_duration = 5 # frames
var SPEED = 100.0
var power = 1
var hp = 2
@onready var sprite = $AnimatedSprite2D
@onready var room_node = get_node("../..")
@onready var player_node = get_node("../../Player")
var frame: int = -1
var potion = null
var potion_drop = {0: 'small_health_potion', 1: 'large_health_potion', 2: 'small_power_potion', 3: 'large_power_potion'}

@onready var raycast = $RayCast2D
var last_player_seen_loc = null
var direction = null

func _ready():
	potion = potion_drop[randi() % 4]
	var potion_path = "res://Scenes/" + potion + ".tscn"
	potion = load(potion_path)

func _physics_process(_delta: float) -> void:
	frame += 1
  
	# if scene begins, begin movement
	if room_node.begin == 1:
		check_player_in_view()
		move()
		jitter(int(float(frame) / float(jitter_duration)) % 2)
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
		direction = (last_player_seen_loc - get_global_position()).normalized()
		if (last_player_seen_loc - get_global_position()).length() < 10:
			last_player_seen_loc = null
		else:
			velocity = direction * SPEED
	else:
		# "patrol"?
		if direction:
			if is_on_wall():
				direction.x = -direction.x
			if is_on_floor() or is_on_ceiling():
				direction.y = -direction.y
			velocity = direction * SPEED

	
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
		
	
func jitter(flag):
	velocity = velocity.rotated(deg_to_rad(jitter_angle if flag else -jitter_angle))

	
func _on_projectile_detector_body_entered(body: Node2D) -> void:
	# if hit move projectile off screen, stop it and lose health
	if body.to_string().begins_with("Projectile"):
		body.set_global_position(Vector2(-100,-100))
		body.active = false
		body.direction = null
		hp -= body.power
		
		# if die, delete self
		if hp <= 0:
			call_deferred("_spawn_potion_and_free")
			
func _spawn_potion_and_free() -> void:
	potion = potion.instantiate()
	room_node.add_child(potion)
	potion.name = "Potion" + potion.name
	potion.set_global_position(get_global_position())
	queue_free()
