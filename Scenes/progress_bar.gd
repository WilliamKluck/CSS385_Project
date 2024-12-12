extends ProgressBar

var weight = 1
var max_health = 100  # Default max health
var current_health = 100  # Default current health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)

# Set the maximum health for the enemy and adjust the bar accordingly
func set_max_health(health):
	max_health = health
	current_health = health
	self.max_value = max_health
	$ProgressBar2.max_value = max_health
	value = max_health
	$ProgressBar2.value = max_health
	print("Max health set to: ", max_health)

# Set weight for smooth interpolation; safeguard against invalid values
func set_weight(value_to_set):
	if value_to_set > 0:
		weight = 100 / value_to_set
	else:
		weight = 1  # Default weight to prevent division by zero

# Update the progress bar values smoothly
func set_bar_value(value_to_set):
	value = value_to_set
	$Timer.start()

# Start processing on timer timeout
func _on_timer_timeout() -> void:
	set_process(true)

# Interpolate ProgressBar2 towards the target value
func _process(_delta):
	$ProgressBar2.value = lerp($ProgressBar2.value, value, 0.1)
	if abs($ProgressBar2.value - value) <= 0.5:
		$ProgressBar2.value = value
		set_process(false)

# Decrease health and update the bars
func decrease_health(value_to_set):
	current_health -= value_to_set
	current_health = clamp(current_health, 0, max_health)  # Ensure health doesn't go below 0
	print("Decreasing health: ", value, " by ", weight * value_to_set)
	set_bar_value(current_health)
