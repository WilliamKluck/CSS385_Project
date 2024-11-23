extends TileMap

# Constants
const ENEMY_SCALE = Vector2(2, 2)
const ROOM_NAME = "Room"

# Variables
var enemy_difficulty = 1
var begin = 0 # 0 is before, 1 is during, 2 is after
var current_enemy_count = 2
var max_enemy_positions = 11
var enemies = []
var rng = RandomNumberGenerator.new()
@onready var initialized = false

# Pause and death menu
@onready var pause_menu = $UI/PauseMenu
@onready var death_menu = $UI/DeathMenu
var paused = false
var dead = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if not initialized:
		setup_enemies()
	handle_pause_input()

# -------------------------------- Helper Functions --------------------------------
# Setup enemies if not already done
func setup_enemies() -> void:
	print("Stage Difficulty ", enemy_difficulty)
	name = ROOM_NAME
	initialized = true

	var enemy_holder = safe_get_node("./Enemies")
	if not enemy_holder: return

	var available_positions = get_enemy_positions()
	if available_positions.size() == 0:
		print("Error: No enemy positions available!")
		return

	manage_enemy_creation(enemy_holder)
	place_enemies(enemy_holder, available_positions)
	print("Amount of Enemies ", len(enemies))
	print("Enemy HP ", enemies[0].hp)
	print("Enemy Power ", enemies[0].power)
	current_enemy_count += 2
	enemy_difficulty += 2

# Retrieve enemy positions from the scene
func get_enemy_positions() -> Array:
	var positions = safe_get_node("./EnemyPositions").get_children()
	if not positions:
		print("Warning: Enemy positions not found!")
	return positions

# Handle enemy creation based on the required number
func manage_enemy_creation(enemy_holder: Node) -> void:
	var num_children = enemy_holder.get_child_count()

	if num_children < current_enemy_count:
		for i in range(current_enemy_count - num_children):
			create_new_enemy(enemy_holder, i + num_children + 1)

	enemies = enemy_holder.get_children()

# Create and add a new enemy to the enemy holder
func create_new_enemy(enemy_holder: Node, enemy_id: int) -> void:
	var enemy_scene = load("res://Scenes/Enemy.tscn")
	if not enemy_scene:
		return

	var new_enemy = enemy_scene.instantiate()
	new_enemy.name = "Enemy" + str(enemy_id)
	new_enemy.scale = ENEMY_SCALE
	enemy_holder.add_child(new_enemy)
	new_enemy.hp *= enemy_difficulty
	new_enemy.power *= enemy_difficulty

# Place all enemies at random valid positions
func place_enemies(enemy_holder: Node, locations: Array) -> bool:
	for enemy in enemy_holder.get_children():
		if locations.size() == 0:
			print("Warning: Not enough positions for all enemies!")
			return false

		var location_selection = rng.randi_range(0, len(locations) - 1)
		enemy.set_global_position(locations[location_selection].get_global_position())
		locations.remove_at(location_selection)

	return true

# Handle pause input and toggle pause menu
func handle_pause_input() -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause_menu()

# Toggle pause menu visibility and game state
func toggle_pause_menu() -> void:
	if dead:
		return
	paused = not paused
	pause_menu.visible = paused
	Engine.time_scale = 0 if paused else 1

# Show death menu and stop the game
func deathMenu() -> void:
	pause_menu.hide()
	death_menu.show()
	Engine.time_scale = 0

# Retrieve a child node safely
func safe_get_node(path: String) -> Node:
	var node = get_node(path)
	if not node:
		print("Error: Node at path '" + path + "' not found!")
	return node
