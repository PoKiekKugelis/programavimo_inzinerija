extends Button

# handles button press event
func _on_pressed() -> void:
	 
	# find enemy in the scene
	var enemy = get_tree().get_first_node_in_group("enemy")
	var combat_screen = get_tree().get_first_node_in_group("combat_screen")
	
	# emit signal to show damage text
	combat_screen.player_action_performed.emit("Player dealt 1 damage!", Color.RED)
	
	# if enemy exists, deal damage
	if enemy:
		var enemy_health = enemy.get_node("Health")
		enemy_health.set_health(enemy_health.health - 1)
		  
