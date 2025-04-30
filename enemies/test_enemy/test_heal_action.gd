extends EnemyAction

@export var heal := -2

func _init() -> void:
	intent = "[color=green]Heal: %d[/color]" % abs(heal)
	message = "[color=green]Enemy healed %d health[/color]" % abs(heal)

func perform_action() -> void:
	if not enemy or not target:
		return
	
	var heal_effect := DamageEffect.new()
	heal_effect.amount = heal
	heal_effect.execute([enemy])
	
	get_tree().create_timer(0.6).timeout.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)
