extends CharacterBody2D


const SPEED = 400.0
var direction = null
var active = false
var room_node = null

func _ready():
	room_node = get_node("..")
	
func _physics_process(_delta: float) -> void:
	movement()
	check_position()
	move_and_slide()

func movement() -> void:
	if direction:
		velocity = direction * SPEED
		
func check_position() -> void:
	if active and (global_position.x < 0 or global_position.x > 1300 or global_position.y < 0 or global_position.y > 800):
		active = false
