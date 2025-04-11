extends Node

signal health_instance_set(health_instance)

var player_health = null

# get the health value
func get_health_instance():
	return player_health
 
# set the health value
func set_health_instance(health_instance):
	player_health = health_instance
	emit_signal("health_instance_set", health_instance)
