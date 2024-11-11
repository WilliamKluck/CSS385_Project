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
var projectiles_created = false
var hp = 10
const heart = "❤️"
var flag = 0
var entry_nodes = []
var enter_from = "Left"
var enter_coords = {"Left": Vector2(182.9998, 391.9999), "Top": Vector2(613.0012, 221.9999), "Right": Vector2(1097.999, 408.9995), "Bottom": Vector2(614.9999, 559.9992)}
var room_node = null
var target_position = null
var room_number = 0

@onready var win_menu = $"../YouWin"

# Flag to check if scene is loaded
var scene_loading_done = false
var children_to_transfer = []

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
	get_node("../HUD/HPLabel").set_text(heart.repeat(hp))
	

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
		# check exits
		for entry_node in entry_nodes:
			# measure distance from exits
			var distance_from = entry_node.get_global_position() - get_global_position()
			
			# if close, set next stage entry point, and load next scene
			if distance_from.length() < 20:
				print(entry_node.name)
				if entry_node.name == "Right":
					enter_from = "Left"
				elif entry_node.name == "Left":
					enter_from = "Right"
				elif entry_node.name == "Top":
					enter_from = "Bottom"
				else:
					enter_from = "Top"
				# get node for entry
				var enter_node = get_node("../RoomEntryPoints/" + enter_from)
				set_global_position(enter_node.get_global_position())
				
				# create new scene
				if room_number == 0:
					var next_scene_path = "res://Scenes/room2.tscn"
					var next_scene_resource = load(next_scene_path)
					
					room_number = 1
					
						# Check if successfully loaded
					if next_scene_resource:
						#Instance the new scene
						var next_scene_instance = next_scene_resource.instantiate()
						var next_room_node = next_scene_instance.get_node(".") #Room node
						
						# set room beginning so next scene starts at beginning
						room_node.begin = 0
						# transfer all children to new scene
						if next_room_node:
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
							return
						else:
							print("Error: 'Room' node not found in the new scene")
					else:
						print("Error: Could not load next scene.")
				elif room_number == 1:
					var next_scene_path = "res://Scenes/room3.tscn"
					var next_scene_resource = load(next_scene_path)
					
					room_number = 2
					
					if next_scene_resource:
						#Instance the new scene
						var next_scene_instance = next_scene_resource.instantiate()
						var next_room_node = next_scene_instance.get_node(".") #Room node
						
						# set room beginning so next scene starts at beginning
						room_node.begin = 0
						# transfer all children to new scene
						if next_room_node:
							# get root for basis
							var the_root = get_tree().root
							# get the children we want to transfer
							children_to_transfer = room_node.get_children()
							var counter = 0
							for child in children_to_transfer:
								room_node.remove_child(child)
								next_room_node.add_child(child)
								
							next_room_node.num_enemy = 1
							
							the_root.add_child(next_room_node)
							the_root.remove_child(room_node)
							return
						else:
							print("Error: 'Room' node not found in the new scene")
					else:
						print("Error: Could not load next scene.")
				else:
					var next_scene_path = "res://Scenes/room3.tscn"
					var next_scene_resource = load(next_scene_path)
					
					if next_scene_resource:
						#Instance the new scene
						var next_scene_instance = next_scene_resource.instantiate()
						var next_room_node = next_scene_instance.get_node(".") #Room node
						
						# set room beginning so next scene starts at beginning
						room_node.begin = 0
						# transfer all children to new scene
						if next_room_node:
							# get root for basis
							var the_root = get_tree().root
							# get the children we want to transfer
							children_to_transfer = room_node.get_children()
							var counter = 0
							for child in children_to_transfer:
								room_node.remove_child(child)
						
							Engine.time_scale = 0
							
							return
						else:
							print("Error: 'Room' node not found in the new scene")
					else:
						print("Error: Could not load next scene.")
					
				

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

func _on_enemy_detector_body_entered(_body: Node2D) -> void:
	flag += 1

func _on_enemy_detector_body_exited(_body: Node2D) -> void:
	flag -= 1

func doDamage() -> void:
	if flag > 0 and ((last_hit_tick and Time.get_ticks_msec() - last_hit_tick > hit_delay) or not last_hit_tick):
		hp = max(hp - 1, 0)
		get_node("../HUD/HPLabel").set_text(heart.repeat(hp))
		last_hit_tick = Time.get_ticks_msec()

		if hp == 0:
			# player has died
			# TODO: trigger death screen, or reset the game, or sth
			pass
