extends EnemyAction

@export var damage := 2

func _init() -> void:
	intent = "[color=red]Damage: %d[/color]" % damage
	message = "[color=red]Enemy dealt %d damage[/color]" % damage

func perform_action() -> void:
	if not enemy or not target:
		return
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := Vector2(400, 450)
	var damage_effect := DamageEffect.new()
	var target_array: Array[Node] = [target]
	damage_effect.amount = damage
	
	enemy.choice.visible = false
	enemy.health_bar.visible = false
	tween.tween_property(enemy, "global_position", end, 0.4)
	tween.tween_callback(damage_effect.execute.bind(target_array))
	tween.tween_interval(0.25)
	tween.tween_property(enemy, "global_position", start, 0.4)
	
	tween.finished.connect(
		func(): 
			Events.enemy_action_completed.emit(enemy)
			enemy.choice.visible = true
			enemy.health_bar.visible = true
	)
	
