extends CharacterBody2D

const SPEED = 300.0 # how fast the player walks
const heart = "❤️" # the UI for health
var character_facing = Vector2(1, 0) # the direction the player is facing
var hp = 10 # the amount of health the player has left

var damage_counter = 0 # how much damage the player will take
var last_hit_tick = null # the last time the player took damage
var hit_delay = 1000 # the delay until the player can take more damage

var last_shot_tick = null # the last time the player shot a projectile
var shot_delay = 250 # the delay until the player can shoot a projectile
var projectiles = [] # the projectiles the player has available to them
var max_projectiles = 15 # the amount of projectiles the player can have
var projectiles_created = false # whether the player has any projectiles

var room_node = null # instance of the current room
var entry_nodes = [] # the directions the player can enter a room from
var enter_from = "Left" # the direction the player will enter the room
var enter_coords = {"Left": Vector2(182.9998, 391.9999), "Top": Vector2(613.0012, 221.9999), "Right": Vector2(1097.999, 408.9995), "Bottom": Vector2(614.9999, 559.9992)} # the location the player will walk to from the entrance
var target_position = null # the location the player will walk to
var children_to_transfer = [] # the children to transfer to the next scene
var max_stages = 3
var stages_complete = 0

const entry_map = {"Left": "Right", "Right": "Left", "Top": "Bottom", "Bottom": "Top"}

func _ready() -> void:
	# get room node for controlling scene stage and changing scene
	room_node = get_node("..")
	# get entry points for deciding which door to enter from
	entry_nodes = get_node("../RoomEntryPoints").get_children()
	# has entry point then player position is atthat entry point
	if enter_from:
		var enter_node = get_node("../RoomEntryPoints/" + enter_from)
		set_global_position(enter_node.get_global_position())
	else:
		print("Error: Entry point not defined")
	# show health bar as amount of health
	get_node("../UI/HUD/HPLabel").set_text(heart.repeat(hp))
	

func _physics_process(_delta: float) -> void:
	# if scene in progress, move like normal
	if room_node.begin == 1: # stage in progress
		# if there are not projectiles, create them
		if not projectiles_created:
			create_projectiles()
		handleInput()
		doDamage()
		move_and_slide()
	# if stage not started, move player into position and close doors
	elif room_node.begin == 0: # stage not started
		# Calculate the vector toward the target position
		target_position = enter_coords[enter_from]
		var direction_vector = target_position - get_global_position()
		# Check if close enough to the target position
		if direction_vector.length() < 5: # Threshold for stopping movement
			# get room node again to ensure correct scene
			room_node = get_node("..")
			room_node.begin = 1
		velocity = direction_vector * 1.5
		move_and_slide()
	else: # stage over
		# remove enter point to allow reassigning
		enter_from = null
		# move to allow player to choose exit
		handleInput()
		move_and_slide()
		
		var near_entry_node = null
		# check exits
		for entry_node in entry_nodes:
			# measure distance from exits
			var distance_from = entry_node.get_global_position() - get_global_position()
			
			# if close, set next stage entry point, and load next scene
			if distance_from.length() < 20:
				near_entry_node = entry_node
				break
		
		if not near_entry_node:
			return
			
		print(near_entry_node.name)
		enter_from = entry_map[near_entry_node.name]
		# get node for entry
		var enter_node = get_node("../RoomEntryPoints/" + enter_from)
		set_global_position(enter_node.get_global_position())
		
		var next_scene_num = stages_complete + 2
		
		# create new scene
		var next_scene_path = "res://Scenes/room" + str(next_scene_num) + ".tscn"
		var next_scene_resource = load(next_scene_path)
		
		if not next_scene_resource:
			print("Error: Could not load next scene.")
			loadEndScene()
			return
		
		#Instance the new scene
		var next_scene_instance = next_scene_resource.instantiate()
		var next_room_node = next_scene_instance.get_node(".") #Room node
		
		# set room beginning so next scene starts at beginning
		room_node.begin = 0
		stages_complete += 1
		if stages_complete == max_stages:
			loadEndScene()
			return
			
		# transfer all children to new scene
		if next_room_node:
			transferChildren(next_room_node)
		else:
			print("Error: 'Room' node not found in the new scene")

func set_enter_from(entry) -> void:
	enter_from = entry

func create_projectiles() -> void:
	for i in range(max_projectiles):
		var new_projectile = load("res://Scenes/projectile.tscn").instantiate()
		new_projectile.name = "Projectile" + str(i)
		get_node("..").add_child(new_projectile)
		projectiles.append(new_projectile)
	projectiles_created = true

func move(moveDirection) -> void:
	# save last known facing direction
	if moveDirection != Vector2(0,0):
		character_facing = moveDirection
	velocity = moveDirection * SPEED

func handleInput() -> void:
	var moveDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move(moveDirection)
	
	# delay time between shots
	if Input.is_action_pressed("shoot") and ((last_shot_tick and Time.get_ticks_msec() - last_shot_tick > shot_delay) or not last_shot_tick):
		var found_available_projectile = null
		for projectile in projectiles:
			if not projectile.active:
				#projectile.active = true
				found_available_projectile = projectile
				break
		
		if found_available_projectile:
			found_available_projectile.set_global_position(get_global_position())
			found_available_projectile.active = true
			found_available_projectile.direction = character_facing
		last_shot_tick = Time.get_ticks_msec()

func _on_enemy_detector_body_entered(body: Node2D) -> void:
	damage_counter += body.power

func _on_enemy_detector_body_exited(body: Node2D) -> void:
	damage_counter -= body.power

func doDamage() -> void:
	if damage_counter > 0 and ((last_hit_tick and Time.get_ticks_msec() - last_hit_tick > hit_delay) or not last_hit_tick):
		hp = max(hp - damage_counter, 0)
		get_node("../UI/HUD/HPLabel").set_text(heart.repeat(hp))
		last_hit_tick = Time.get_ticks_msec()

		if hp <= 0:
			room_node.deathMenu()

func loadEndScene() -> void:
	var end_scene_path = "res://Scenes/end.tscn"
	var base = get_tree().root
	for child in base.get_children():
		base.remove_child(child)
		child.queue_free()
	# Load the new scene and instance it
	var new_scene = load(end_scene_path).instantiate()
	# Add the new scene to the root node
	base.add_child(new_scene)

func transferChildren(next_room_node) -> void:
	# get root for basis
	var the_root = get_tree().root
	# get the children we want to transfer
	children_to_transfer = room_node.get_children()
	# transfer each child
	for child in children_to_transfer:
		room_node.remove_child(child)
		next_room_node.add_child(child)
	the_root.add_child(next_room_node)
	the_root.remove_child(room_node)
