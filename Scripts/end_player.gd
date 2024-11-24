extends CharacterBody2D

var damage_animation_lock = false
const SPEED = 300.0
@onready var room_node = get_node("..")
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var projectile_scene = preload("res://Scenes/projectile.tscn") # Reusable projectile template
var character_facing = Vector2(1, 0) # Direction player faces
var current_animation = "" # Track the current animation
# Audio Variables
var current_audio = ""
@export var audio_files = {
	"battle": "res://Assets/audio/battle.mp3"
}
var exit = false

func _ready() -> void:
	
	pass
	
func _physics_process(_delta: float) -> void:
	if not exit:
		set_music()
		handleInput()
	else:
		move(Vector2(0,1))
	move_and_slide()

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

func set_animation(new_animation: String) -> void:
	if current_animation == new_animation:
		return # Avoid restarting the same animation
	
	current_animation = new_animation
	animation_player.play(new_animation)

# Process player input for movement and actions
func handleInput() -> void:
	var moveDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move(moveDirection)


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("entered")
	exit = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	var video = get_node("../VideoStreamPlayer")
	video.play()
	


func _on_video_stream_player_finished() -> void:
	var video = get_node("../VideoStreamPlayer")
	video.play()
