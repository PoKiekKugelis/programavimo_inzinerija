class_name Health
extends Node

# signals for health changes
signal max_health_changed(diff: int)  # emitted when max health changes
signal health_changed(diff: int)      # emitted when current health changes  
signal health_depleted                # emitted when health reaches 0

# configuration variables
@export var max_health: int     # maximum health value
@export var immortality: bool = false : set = set_immortality, get = get_immortality
@onready var health: int = max_health : set = set_health, get = get_health  # current health

# timer for temporary immortality
var immortality_timer: Timer = null

# sets maximum health with validation
func set_max_health(value: int):
	# ensure health never goes below 1
	var clamped_value = 1 if value <= 0 else value
	
	# only emit signal if value actually changed
	if not clamped_value == max_health:
		var difference = clamped_value - max_health
		max_health = value
		max_health_changed.emit(difference)
		
		# adjust current health if over new max
		if health > max_health:
			health = max_health

# gets maximum health value
func get_max_health() -> int:
	return max_health

# sets current health with validation
func set_health(value: int):
	# block damage if immortal
	if value < health and immortality:
		print("Damage blocked due to immortality!")
		return
		
	# clamp value between 0 and max health
	var clamped_value = clampi(value, 0, max_health)
	
	# only update if value changed
	if clamped_value != health:
		var difference = clamped_value - health
		health = clamped_value
		health_changed.emit(difference)
		
		# check for death
		if health <= 0:
			health_depleted.emit()

# gets current health value
func get_health():
	return health
	
# sets immortality state    
func set_immortality(value: bool):
	immortality = value
	
# grants temporary immortality    
func set_temporary_immortality(time: float):
	# initialize timer if doesn't exist
	if immortality_timer == null:
		immortality_timer = Timer.new()
		immortality_timer.one_shot = true
		add_child(immortality_timer)
		
		# clean up previous connections
		if immortality_timer.timeout.is_connected(set_immortality):
			immortality_timer.timeout.disconnect(set_immortality)
		
		# configure timer
		immortality_timer.set_wait_time(time)
		immortality_timer.timeout.connect(set_immortality.bind(false))
		immortality = true
		immortality_timer.start()

# gets current immortality state
func get_immortality() -> bool:
	return immortality
