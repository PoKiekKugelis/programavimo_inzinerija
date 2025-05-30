extends TextureProgressBar

@onready var shield_bar: TextureProgressBar = $ShieldBar
@onready var shield_head: TextureProgressBar = $ShieldHead

# runs when node enters the scene tree
func _ready() -> void:
	# try to get existing health instance
	var health = GlobalHealth.get_health_instance()
	# if health exists, set up bar immediately
	if health: setup_health_bar(health)
	else: GlobalHealth.health_instance_set.connect(setup_health_bar)# otherwise wait for health instance to be available

# configures health bar with a health component
func setup_health_bar(health: Health) -> void:
	# set max and current health values
	max_value = health.max_health + health.shield
	value = health.health
	shield_bar.value = value + health.shield
	shield_bar.max_value = health.max_health + health.shield
	# set tooltip
	tooltip_text = "%s/%s" % [health.health, health.max_health]
	# connect signals
	health.health_changed.connect(_update_bar)
	health.shield_changed.connect(update_shield)
	# clean up signal connection if we used the waiting approach
	if GlobalHealth.health_instance_set.is_connected(setup_health_bar):
		GlobalHealth.health_instance_set.disconnect(setup_health_bar)

# updates health bar display
func _update_bar(diff: int) -> void:
	value += diff
	shield_bar.value = value
	var health = GlobalHealth.get_health_instance()
	tooltip_text = "%s/%s" % [health.health, health.max_health]
	if health.shield > 0:
		max_value = health.max_health + health.shield
		shield_bar.max_value = health.max_health + health.shield
		shield_bar.value = value + health.shield

# get current health and update display
func update_shield() -> void:
	var health = GlobalHealth.get_health_instance()
	shield_bar.tooltip_text = "%s shield" % health.shield
	max_value = health.max_health + health.shield
	shield_bar.max_value = health.max_health + health.shield
	shield_bar.value = value + health.shield
	if health.shield > 0:
		shield_head.z_index = 0
		shield_bar.mouse_filter = shield_bar.MOUSE_FILTER_PASS
	else: shield_head.z_index = -1; shield_bar.mouse_filter = MOUSE_FILTER_IGNORE
