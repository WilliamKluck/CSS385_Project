extends TileMap

var room_node = null

func _ready():
	room_node = get_node("..")
	# Make the entire TileMap invisible
	visible = false
	
	# Disable collisions by setting the collision layer and mask to 0
	tile_set.set_physics_layer_collision_layer(0, 0)
	tile_set.set_physics_layer_collision_mask(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if room_node.begin:
		enable_tiles()
			
func enable_tiles() -> void:
	# Make the TileMap visible
	visible = true
	
	# Enable collisions
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.set_physics_layer_collision_mask(0, 6)
