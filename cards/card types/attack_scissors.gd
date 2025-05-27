extends Card

func apply_effects(targets: Array[Node], scene_context: Node) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = 3
	damage_effect.execute(targets)
	
	# Play animation on the player
	if scene_context.has_method("play_player_animation"):
		scene_context.play_player_animation("place_scissors")
