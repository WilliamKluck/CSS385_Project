extends TileMap

@onready var room_node = get_node("..")
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var projectile_scene = preload("res://Scenes/projectile.tscn") # Reusable projectile template


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
