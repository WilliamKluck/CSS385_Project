extends TileMap
# RESPONSIBLE FOR SWITCHING SCENE TO POST
var room_node = null
var enemy_nodes = []
func _ready():
	disable_tiles()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	room_node = get_node("..")
	var children = get_node("../Enemies/").get_children()
	for node in children:
		if node.get_name().begins_with("Enemy"):
			enemy_nodes.append(node)
	if room_node.begin == 1:
		enable_tiles()
	for node in enemy_nodes:
		
		if not node:
			enemy_nodes.erase(node)
			if len(enemy_nodes) == 0:
				room_node.begin = 2 
				$"../Player/SoundEffects/StageClear".play()
				disable_tiles()
	
func enable_tiles() -> void:
	# Make the TileMap visible
	visible = true
	
	# Enable collisions
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.set_physics_layer_collision_mask(0, 6)
	
func disable_tiles() -> void:
	# Make the TileMap invisible
	visible = false
	
	# Disable collisions
	tile_set.set_physics_layer_collision_layer(0, 0)
	tile_set.set_physics_layer_collision_mask(0, 0)
