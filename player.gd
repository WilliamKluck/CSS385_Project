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

func _ready() -> void:
	get_node("../HUD/HPLabel").set_text(heart.repeat(hp))

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
	
func _physics_process(delta: float) -> void:
	if has_gone == 0:
		has_gone = 1
		go()
	handleInput()
	doDamage()
	move_and_slide()

func handleInput():
	var moveDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# save last known facing direction
	if moveDirection != Vector2(0,0):
		character_facing = moveDirection

	velocity = moveDirection * SPEED
	
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
		hp = max(hp - 1, 0)
		#var old_hp_text = get_node("../HUD/HPLabel").get_text()
		get_node("../HUD/HPLabel").set_text(heart.repeat(hp))
		last_hit_tick = Time.get_ticks_msec()
		#timer = Time.get_ticks_msec()
		if hp == 0:
			# player has died
			# TODO: trigger death screen, or reset the game, or sth
			pass
