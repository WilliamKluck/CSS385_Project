extends TileMap

var begin = 0 # 0 is before, 1 is during, 2 is after
var num_enemy = 3 # to allow changing in other scenes
var enemies = [] # to store enemies and allow creation
var rng = RandomNumberGenerator.new() # to select enemy placement
var initialized = null # decides if we need more enemies

# pause menu additions
@onready var pause_menu = $PauseMenu
var paused = false

func _ready() -> void:
	initialized = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not initialized:
		name = "Room"
		initialized = true
		var enemy_holder = get_node("./Enemies")
		if enemy_holder:
			var num_children = enemy_holder.get_child_count()
			if num_children >= num_enemy:
				enemies = enemy_holder.get_children()
			else:
				for i in range(num_enemy - num_children):
					var enemy_scene = load("res://Scenes/Enemy.tscn")
					var new_enemy = enemy_scene.instantiate()
					new_enemy.name = "Enemy" + str(num_children + i + 1)
					enemy_holder.add_child(new_enemy)
				enemies = enemy_holder.get_children()
			for enemy in enemies:
				#enemy.set_process(true)
				var locations = get_node("./EnemyPositions").get_children()
				var location_selection = rng.randf_range(0,len(locations))
				enemy.set_global_position(locations[location_selection].get_global_position())
				locations.erase(locations[location_selection])
	# pause menu additions
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	
# pause menu additions
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused
