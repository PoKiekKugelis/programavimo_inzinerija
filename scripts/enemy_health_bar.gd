extends TextureProgressBar

# initializes the health bar with a health component
func setup_health_bar(health: Health) -> void:
	# prevent duplicate signal connections
	if health.health_changed.is_connected(_update_bar):
		health.health_changed.disconnect(_update_bar)
	
	# connect to health changes
	health.health_changed.connect(_update_bar)
	
	# set initial health values
	max_value = health.max_health
	value = health.health

# updates the health bar when health changes
func _update_bar(diff: int) -> void:
	value += diff
	
   
