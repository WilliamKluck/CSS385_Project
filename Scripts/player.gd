extends CharacterBody2D


const SPEED = 300.0
var last_shot_tick = null
var last_hit_tick = null
var shot_delay = 250
var hit_delay = 1000
var character_facing = Vector2(1, 0)
var projectiles = [] 
var buffer_start = 0
var max_projectiles = 15
var has_gone = 0
var hp = 10
const heart = "❤️"
var flag = 0
var enter_from = "Left"
var dict = {"Left": Vector2(182.9998, 391.9999), "Top": Vector2(613.0012, 221.9999), "Right": Vector2(1097.999, 408.9995), "Bottom": Vector2(614.9999, 604.9991)}
var room_node = null
var target_position = null

func _ready() -> void:
	room_node = get_node("..")
	if enter_from:
		var enter_node = get_node("../" + enter_from)
		set_global_position(enter_node.get_global_position())
		print(get_global_position())
	get_node("../HUD/HPLabel").set_text(heart.repeat(hp))
	target_position = dict[enter_from]

func _physics_process(delta: float) -> void:
	if room_node.begin:
		if has_gone == 0:
			has_gone = 1
			go()
		handleInput()
		doDamage()
	else:
		# Calculate the vector toward the target position
		var direction_vector = target_position - get_global_position()
		# Check if close enough to the target position
		if direction_vector.length() < 2.1: # Threshold for stopping movement
			print("Arrived at target position!")
			room_node.begin = 1
		velocity = direction_vector * 2
	
	move_and_slide()

func go():
	for i in range(max_projectiles):
		var new_projectile = load("res://Scenes/projectile.tscn").instantiate()
		print(new_projectile)
		new_projectile.name = "Projectile" + str(i)
		get_node("..").add_child(new_projectile)
		projectiles.append(new_projectile)
		#print(new_projectile.get_property_list())
		#for s in new_projectile.get_property_list():
			#print(s)
	print(get_node("..").get_children())
	
func move(moveDirection) -> void:
	# save last known facing direction
	if moveDirection != Vector2(0,0):
		character_facing = moveDirection
	velocity = moveDirection * SPEED
	
func handleInput():
	var moveDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move(moveDirection)
	
	#print(Input.is_action_pressed("shoot"))
	
	# delay time between shots
	if Input.is_action_pressed("shoot") and ((last_shot_tick and Time.get_ticks_msec() - last_shot_tick > shot_delay) or not last_shot_tick):
		#var new_projectile = load("res://Scenes/projectile.tscn").instantiate()
		#var parent = get_node("..")
		#parent.add_child(new_projectile)
		#new_projectile.set_global_position(get_global_position())
		#new_projectile.direction = character_facing
		#print("should shoot")
		var found_available_projectile = null
		for projectile in projectiles:
			#print("pass")
			if not projectile.active:
				#projectile.active = true
				found_available_projectile = projectile
				break
				
		if found_available_projectile:
			print("found")
			print(found_available_projectile)
			
			found_available_projectile.set_global_position(get_global_position())
			found_available_projectile.active = true

			print(found_available_projectile.get_global_position())
			print(get_global_position())
			found_available_projectile.direction = character_facing
				
		last_shot_tick = Time.get_ticks_msec()
		
		
		


func _on_enemy_detector_body_entered(body: Node2D) -> void:
	flag += 1


func _on_enemy_detector_body_exited(body: Node2D) -> void:
	flag -= 1
	
func doDamage() -> void:
	if flag > 0 and ((last_hit_tick and Time.get_ticks_msec() - last_hit_tick > hit_delay) or not last_hit_tick):
		#print("enemy detected")
		print(flag)
		hp -= 1
		#var old_hp_text = get_node("../HUD/HPLabel").get_text()
		get_node("../HUD/HPLabel").set_text(heart.repeat(hp))
		last_hit_tick = Time.get_ticks_msec()
		#timer = Time.get_ticks_msec()
