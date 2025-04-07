class_name DamageEffect
extends Effect

var amount := 0


func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is TestEnemy: #cia tikrai nesita reik rasyt bet as nezinau kaip cia pagal musu ta enemy padaryt :(
			target.take_damage(amount)
