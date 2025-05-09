class_name DamageEffect
extends Effect

var amount := 0

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is TestEnemy or target is Player:
			var enemy_health = target.get_node("Health")
			enemy_health.receive_damage(amount)

func heal(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is TestEnemy or target is Player:
			var enemy_health = target.get_node("Health")
			enemy_health.apply_heal(amount)
