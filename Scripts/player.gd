extends CharacterBody2D

# Node/Scene Variables
@onready var hud_hp_label = get_node("../UI/HUD/HPLabel") # Health display
@onready var room_entry_points = get_node("../RoomEntryPoints")
@onready var room_node = get_node("..")
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var projectile_scene = preload("res://Scenes/projectile.tscn") # Reusable projectile template

# Movement Variables
const SPEED = 300.0
var character_facing = Vector2(1, 0) # Direction player faces
var target_position = null # Position the player moves toward in auto-walk

# Animation Variables
var current_animation = "" # Track the current animation
var damage_animation_lock = false

# Audio Variables
var current_audio = ""
@export var audio_files = {
	"battle": "res://Assets/audio/battle.mp3"
}

# Health Variables
var hp = 10
const heart = "❤️"
var damage_counter = 0
var last_hit_tick = null
const hit_delay = 1000 # Time between damage ticks (ms)

# Projectile Variables
const max_projectiles = 15
var projectiles = [] # List of reusable projectiles
var projectiles_created = false # Ensure projectiles are instantiated once
var last_shot_tick = null
const shot_delay = 250 # Time between shots (ms)
var projectile_power = 1

# Room/Stage Variables
const TARGET_THRESHOLD = 5.0
const ENTRY_PROXIMITY = 20.0
var entry_nodes = [] # List of potential room entry points
var enter_from = "Left" # Entry direction
var max_stages = 3
var stages_complete = 0
var children_to_transfer = [] 

# Maps entry direction to its opposite for seamless transitions
const entry_map = {"Left": "Right", "Right": "Left", "Top": "Bottom", "Bottom": "Top"}
var enter_coords = {
	"Left": Vector2(182.9998, 391.9999), 
	"Top": Vector2(613.0012, 233.9999), 
	"Right": Vector2(1097.999, 408.9995), 
	"Bottom": Vector2(614.9999, 559.9992)
} # the location the player will walk to from the entrance

func _ready() -> void:
	show_controls()
	initialize_room() # Setup entry points
	initialize_player_position() # Spawn player at correct entrance
	update_health_ui() # Show initial health

func _physics_process(_delta: float) -> void:
	# hacky way of forcing the player out of the wall
	position.x = max(position.x, 6)
	position.x = min(position.x, 378)
	position.y = max(position.y, 27)
	position.y = min(position.y, 212)
	if room_node.paused:
		return
	set_music()
	# Control logic depending on stage state
	if room_node.begin == 1: # Ongoing stage
		process_stage_in_progress()
	elif room_node.begin == 0: # Awaiting start
		process_stage_not_started()
	else: # Stage Complete
		process_stage_over()

# ------------------------------------------ Initialization Helpers --------------------------------
# Setup the room environment and entry points
func initialize_room() -> void:
	room_node = get_node("..")
	entry_nodes = room_entry_points.get_children()
	create_shoot_animation()

# Place player at the correct entry node based on their direction of entry
func initialize_player_position() -> void:
	if enter_from:
		var enter_node = get_node("../RoomEntryPoints/" + enter_from)
		set_global_position(enter_node.get_global_position())
	else:
		print("Error: Entry point not defined")

# Update health bar with current HP
func update_health_ui() -> void:
	hud_hp_label.set_text(heart.repeat(hp))
	print("Player Health ", hp)
# ------------------------------------------ End Initialization Helpers ----------------------------

# ------------------------------------------ Stage Processing --------------------------------------
# Manage player and stage state during gameplay
func process_stage_in_progress() -> void:
	if not is_instance_valid(room_node): return
	if not projectiles_created: create_projectiles() # lazy projectile creation
	handleInput()
	doDamage()
	move_and_slide()

# Automatically walk the player to the starting position
func process_stage_not_started() -> void:
	target_position = enter_coords[enter_from]
	var direction_vector = target_position - get_global_position()
	if direction_vector.length() < TARGET_THRESHOLD: # Arrived at target
		room_node.begin = 1
		velocity = Vector2.ZERO
	else:
		velocity = direction_vector.normalized() * SPEED
	move_and_slide()

# Manage the state when the stage is complete (before moving to another room or ending)
func process_stage_over() -> void:
	enter_from = null # Reset entry direction to prevent incorrect movement
	handleInput()
	move_and_slide()

	# Check if the player is near an entry node to transition to the next room
	var near_entry_node = check_for_near_entry_node()
	if near_entry_node:
		handle_entry_node(near_entry_node) # Handle the transition to the next room

# Check if the player is close enough to any room entry node
func check_for_near_entry_node() -> Node2D:
	for entry_node in entry_nodes:
		var distance_from = entry_node.get_global_position() - get_global_position()
		if distance_from.length() < ENTRY_PROXIMITY:
			return entry_node # Return the node the player is near
	return null # No entry node is close enough

# Handle the transition to a new room via the detected entry node
func handle_entry_node(entry_node: Node2D) -> void:
	reset_projectiles() # Clear and reset projectiles for the next room
	enter_from = entry_map[entry_node.name] # Determine entry direction for the next room
	var enter_node = get_node("../RoomEntryPoints/" + enter_from)
	set_global_position(enter_node.get_global_position()) # Move player to the corresponding entry point

	# Determine the next room based on current progress
	var next_scene_num = stages_complete + 2
	
	stages_complete += 1 # Track stage progression
	if stages_complete == max_stages: # Check if all stages are complete
		loadEndScene() # Load the end scene if this is the last stage
		return
	
	var next_scene_path = "res://Scenes/room" + str(next_scene_num) + ".tscn"
	var next_scene_resource = load(next_scene_path)
	if not next_scene_resource: # Handle missing or incorrect room paths
		print("Error: Could not load next scene.")
		loadEndScene()
		return

	var next_scene_instance = next_scene_resource.instantiate()
	var next_room_node = next_scene_instance.get_node(".")
	if not next_room_node: # Ensure the new room has a valid root node
		print("Error: 'Room' node not found in the new scene")
		return
		
	
	next_room_node.current_enemy_count = room_node.current_enemy_count # Transfer enemy count
	next_room_node.enemy_difficulty = room_node.enemy_difficulty
	room_node.begin = 0 # Reset the room's state
	
	
	transferChildren(next_room_node) # Transfer room contents to the new scene
# ------------------------------------------ End Stage Process Helpers -----------------------------

# ------------------------------------------ Projectile and Movement Helpers -----------------------
# Create a pool of reusable projectiles for the player
func create_projectiles() -> void:
	if projectiles_created:
		return

	for i in range(max_projectiles):
		var new_projectile = projectile_scene.instantiate()
		new_projectile.name = "Projectile" + str(i)
		get_node("..").add_child(new_projectile)
		projectiles.append(new_projectile)
		new_projectile.power = projectile_power
	projectiles_created = true

# Free the pool of reusable projectiles
func reset_projectiles() -> void:
	for projectile in projectiles:
		if is_instance_valid(projectile):
			projectile.queue_free()
	projectiles.clear()
	projectiles_created = false

func change_projectile_power(delta: int) -> void:
	projectile_power += delta
	for projectile in projectiles:
		if is_instance_valid(projectile):
			projectile.power = projectile_power
	print("Projectile Power ", projectiles[0].power)

# Move the character based on input and update facing direction
func move(moveDirection) -> void:
	# Save last known facing direction
	if moveDirection != Vector2(0,0):
		character_facing = moveDirection
	velocity = moveDirection * SPEED
	
	# Update animation based on movement
	if moveDirection.x > 0:
		sprite.flip_h = false
		set_animation("walkHorizontal")
	elif moveDirection.x < 0:
		sprite.flip_h = true
		set_animation("walkHorizontal")
	elif moveDirection.y < 0:
		set_animation("walkUp")
	elif moveDirection.y > 0:
		set_animation("walkHorizontal")
	else:
		set_animation("idle") # Default to idle when not moving
# ------------------------------------------ End Projectile and Movement Helpers -------------------

# ------------------------------------------ Audio Helpers -----------------------------------------
func set_music() -> void:
	#if room_node.paused:
		#play_music("pause")
	#elif room_node.dead:
		#play_music("dead")
	#elif len(room_node.enemies) > 0:
	play_music("battle")
	#elif stages_complete == max_stages:
		#play_music("end")
	#else:
		#play_music("idle")
		
# Play shoot sound effect
func play_shoot_sound_effect():
	# duplicate to enable playing sound effects in parallel
	var newPlayer = $SoundEffects/Shoot.duplicate()
	newPlayer.name = "Shoot" + str(Time.get_ticks_msec())
	$SoundEffects.add_child(newPlayer)
	newPlayer.play()
	
func play_damage_sound_effect():
	var newPlayer = $SoundEffects/Damage.duplicate()
	newPlayer.name = "Damage" + str(Time.get_ticks_msec())
	$SoundEffects.add_child(newPlayer)
	newPlayer.play()
	
# Streams audio files
func play_music(audio_name: String) -> void:
	var music = $SoundEffects/BackgroundMusic
	if current_audio != audio_name:
		current_audio = audio_name
		
		# Load the audio steam dynamically
		var stream = ResourceLoader.load(audio_files[audio_name], "AudioStream")
		if stream:
			music.stream = stream
			music.play()
		else:
			print("Failed to load audio: " + audio_name)
	
# ------------------------------------------ Animation Helpers -------------------------------------
func set_animation(new_animation: String) -> void:
	if damage_animation_lock and new_animation != "die":
		return # Block other animations except "die" while locked
	if current_animation == "die":
		return # No animation changes after death
	if current_animation == new_animation:
		return # Avoid restarting the same animation
	
	current_animation = new_animation
	animation_player.play(new_animation)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "takeDamage" or anim_name == "shoot":
		damage_animation_lock = false # Unlock after damage animation
	if anim_name == "shoot":
		shoot_projectile()
		play_shoot_sound_effect()
	if anim_name == "die":
		room_node.dead = true
		room_node.deathMenu()
		return

func create_shoot_animation() -> void:
	var animation = animation_player.get_animation("shoot")
	if not animation:
		animation = Animation.new()
		animation_player.add_animation("shoot", animation)

	# Reset the animation and set the correct length
	animation.length = shot_delay / 1000.0  # Duration of the shot animation in seconds
	animation.length -= 0.1
	
	# Create a property track for the 'frame' property of the Sprite
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, String(sprite.get_path()) + ":frame")  # Target the 'frame' property of the Sprite
	
	# Set keyframes for the Sprite's `frame` property (this assumes your sprite has a `frame` property)
	# Start from frame 120 and end at frame 123 (or however you want the animation to span)
	animation.track_insert_key(0, 0.0, 120)  # Keyframe at time 0 (start) for frame 120
	animation.track_insert_key(0, animation.length, 123)  # Keyframe at the end time for frame 123
#------------------------------------------ End Animation Helpers ---------------------------------

# ------------------------------------------ Damage and Input Helpers ------------------------------
# Process player input for movement and actions
func handleInput() -> void:
	var moveDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	moveDirection = moveDirection.normalized()
	move(moveDirection)
	check_and_shoot()

# Check if the player is attempting to shoot and if allowed by shot delay
func check_and_shoot() -> void:
	if not Input.is_action_pressed("shoot"):
		return
	if last_shot_tick and Time.get_ticks_msec() - last_shot_tick < shot_delay:
		return
	
	set_animation("shoot")
	damage_animation_lock = true
	last_shot_tick = Time.get_ticks_msec()

# Activate an available projectile and launch it in the player's facing direction
func shoot_projectile() -> void:
	var found_available_projectile = null
	for projectile in projectiles:
		if not projectile.active:
			found_available_projectile = projectile
			break
	
	if found_available_projectile:
		found_available_projectile.set_global_position(get_global_position())
		found_available_projectile.active = true
		found_available_projectile.direction = character_facing

		# Calculate the rotation angle based on the player's facing direction
		var angle = character_facing.angle()  # Get the angle of the facing direction (in radians)
		
		# Apply the angle to the projectile's rotation
		found_available_projectile.rotation = angle  # Apply this angle in radians

# Apply damage to the player based on damage counters and delay
func doDamage() -> void:
	if room_node.dead:
		return
	if damage_counter <= 0:
		return
	if last_hit_tick and Time.get_ticks_msec() - last_hit_tick < hit_delay:
		return
	
	hp = max(hp - damage_counter, 0)
	hud_hp_label.set_text(heart.repeat(hp))
	last_hit_tick = Time.get_ticks_msec()
	
	play_damage_sound_effect()
	set_animation("takeDamage") # Play damage animation
	damage_animation_lock = true
	
	if hp <= 0:
		handle_death()

func handle_death() -> void:
	room_node.dead = true
	set_animation("die")
# ------------------------------------------ End Damage and Input Helpers --------------------------

# ------------------------------------------ Scene Loading Helpers ---------------------------------
func show_controls() -> void:
	room_node.call_deferred("toggle_pause_menu")
	
# Load the final end scene when the game is complete
func loadEndScene() -> void:
	var end_scene_path = "res://Scenes/end.tscn/"
	var base = get_tree().root

	# Cleanup and free all existing nodes
	for child in base.get_children():
		if is_instance_valid(child):
			child.queue_free()

	# Load and instance the new scene
	var new_scene = load(end_scene_path).instantiate()
	
	base.add_child(new_scene)

# Transfer children (e.g., enemies, player) to the next room
func transferChildren(next_room_node) -> void:
	# Validate the current room node
	if not is_instance_valid(room_node):
		return
		
	var the_root = get_tree().root
	
	# Transfer children
	children_to_transfer = room_node.get_children()
	for child in children_to_transfer:
		if child.name == "Pit": 
			continue
		#if child.name.starts_with("Potion"):
			#continue
		room_node.remove_child(child)
		next_room_node.add_child(child)
	
	# Add the new room to the root and clean up the old room
	the_root.add_child(next_room_node)
	
	# Remove and free the current room node safely
	the_root.remove_child(room_node)
	room_node.queue_free()
	
	room_node = next_room_node
# ------------------------------------------ End Scene Loading Helpers -----------------------------

# ------------------------------------------ Collision Detection Helpers ---------------------------
# Increase damage counter when entering an enemy's detection area
func _on_enemy_detector_body_entered(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	#if hasattr(body, "power"):
	damage_counter += body.power

# Decrease damage counter when exiting an enemy's detection area
func _on_enemy_detector_body_exited(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	#if hasattr(body, "power"):
	damage_counter -= body.power
# ------------------------------------------ End Collision Detection Helpers -----------------------


func _on_area_2d_area_entered(_area: Area2D) -> void:
	move(Vector2(-10,0)) # Replace with function body.


func _on_stage_clear_finished() -> void:
	play_music("battle")
