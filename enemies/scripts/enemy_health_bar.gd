extends TextureProgressBar
var enemy_health : Health
func _ready() -> void:
	var enemy = owner
	enemy_health = enemy.get_node("Health")
	setup_health_bar(enemy_health)

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
	# set the tooltip
	tooltip_text = "%s/%s" % [health.health, health.max_health]

# updates the health bar when health changes
func _update_bar(diff: int) -> void:
	value += diff
	tooltip_text = "%s/%s" % [enemy_health.health, enemy_health.max_health]

   
