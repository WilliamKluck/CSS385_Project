extends CharacterBody2D


const SPEED = 300.0
var last_shot_tick = null
var shot_delay = 250
var character_facing = Vector2(1, 0)
var projectiles = [] 
var buffer_start = 0
var max_projectiles = 15
var has_gone = 0

func go():
	for i in range(max_projectiles):
		var new_projectile = load("res://Scenes/projectile.tscn").instantiate()
		print(new_projectile)
		get_node("..").add_child(new_projectile)
		projectiles.append(new_projectile)
	print(get_node("..").get_children())
	
func _physics_process(delta: float) -> void:
	if has_gone == 0:
		has_gone = 1
		go()
	handleInput()
	move_and_slide()

func handleInput():
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# save last known facing direction
	if moveDirection != Vector2(0,0):
		character_facing = moveDirection

	velocity = moveDirection * SPEED
	
	# delay time between shots
	if Input.is_action_pressed("shoot") and ((last_shot_tick and Time.get_ticks_msec() - last_shot_tick > shot_delay) or not last_shot_tick):
		#var new_projectile = load("res://Scenes/projectile.tscn").instantiate()
		#var parent = get_node("..")
		#parent.add_child(new_projectile)
		#new_projectile.set_global_position(get_global_position())
		#new_projectile.direction = character_facing
		var found_available_projectile = null
		for projectile in projectiles:
			print("pass")
			if not projectile.active:
				projectile.active = true
				found_available_projectile = projectile
				break
				
		if found_available_projectile:
			print("found")
			
			found_available_projectile.set_global_position(get_global_position())
			print(found_available_projectile.get_global_position())
			print(get_global_position())
			found_available_projectile.direction = character_facing
				
		last_shot_tick = Time.get_ticks_msec()
		
		
		
