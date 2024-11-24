extends Node2D

@onready var player = get_node("../Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_area_2d_body_entered(_body: Node2D) -> void:
	player.hp += 1
	player.update_health_ui()
	queue_free()
