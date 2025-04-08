class_name DamageEffect
extends Effect

var amount := 0


func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is TestEnemy: #cia tikrai nesita reik rasyt bet as nezinau kaip cia pagal musu ta enemy padaryt :(
			var enemy_health = target.get_node("Health")
			enemy_health.set_health(enemy_health.health - amount)
