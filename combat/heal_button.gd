extends Button

# handles heal button press event
func _on_pressed() -> void:
	# get reference to combat screen
	var combat_screen = get_tree().get_first_node_in_group("combat_screen")
	combat_screen.player_action_performed.emit("Player healed 1 health!", Color.RED)
	
	# access player's health component
	var player_health = GlobalHealth.get_health_instance()
	
	# if health component exists, apply heal
	if player_health:
		player_health.set_health(player_health.health + 1)
		
