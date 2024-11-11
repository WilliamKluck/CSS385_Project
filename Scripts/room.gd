extends TileMap

var begin = null
var enemies = []
var rng = RandomNumberGenerator.new()

# pause menu additions
@onready var pause_menu = $PauseMenu
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies = get_node("./Enemies").get_children()
	for enemy in enemies:
		var locations = get_node("./EnemyPositions").get_children()
		var location_selection = rng.randf_range(0,len(locations))
		enemy.set_global_position(locations[location_selection].get_global_position())
		locations.erase(locations[location_selection])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
