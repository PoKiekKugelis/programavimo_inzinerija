extends Card
class_name HealCard

@export var heal_amount: int = 3

func apply_effects(targets: Array[Node]) -> void:
	var health = GlobalHealth.get_health_instance()
	health.apply_heal(heal_amount)
