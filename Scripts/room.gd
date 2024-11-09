extends TileMap

var begin = null
var enemies = []
var rng = RandomNumberGenerator.new()
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
	pass
