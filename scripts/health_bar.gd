extends TextureProgressBar

# runs when node enters the scene tree
func _ready() -> void:
	# try to get existing health instance
	var health = GlobalHealth.get_health_instance()
	
	# if health exists, set up bar immediately
	if health:
		setup_health_bar(health)
	else:
		# otherwise wait for health instance to be available
		GlobalHealth.health_instance_set.connect(setup_health_bar)

# configures health bar with a health component
func setup_health_bar(health) -> void:
	# set max and current health values
	max_value = health.max_health
	value = health.health
	
	# connect to health change signals
	health.health_changed.connect(_update_bar)
	
	# clean up signal connection if we used the waiting approach
	if GlobalHealth.health_instance_set.is_connected(setup_health_bar):
		GlobalHealth.health_instance_set.disconnect(setup_health_bar)

# updates health bar display
func _update_bar(_diff: int) -> void:
	# get current health and update display
	var health = GlobalHealth.get_health_instance()
	if health:
		value = health.get_health()
