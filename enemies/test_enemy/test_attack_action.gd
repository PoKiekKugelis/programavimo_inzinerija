extends EnemyAction

@export var damage := 2

func _init() -> void:
	message = "[color=red]Enemy dealt %d damage[/color]" % damage

func perform_action() -> void:
	if not enemy or not target:
		return
	var anim_sprite = enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	anim_sprite.sprite_frames.set_animation_loop("attack", false)
	anim_sprite.play("attack")
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := Vector2(400, 400)
	var damage_effect := DamageEffect.new()
	var target_array: Array[Node] = [target]
	damage_effect.amount = damage
	
	enemy.intent_ui.visible = false
	enemy.health_bar.visible = false
	tween.tween_property(enemy, "global_position", end, 0.4)
	tween.tween_callback(damage_effect.execute.bind(target_array))
	tween.tween_interval(0.25)
	tween.tween_property(enemy, "global_position", start, 0.4)
	
	tween.finished.connect(
		func(): 
			anim_sprite.play("idle")
			#Events.enemy_action_completed.emit(enemy)
			enemy.intent_ui.visible = true
			enemy.health_bar.visible = true
			Events.enemy_action_completed.emit(enemy)
	)
	
