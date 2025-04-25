extends Card
class_name ShieldCard

@export var shield_amount: int = 5

func apply_effects(targets: Array[Node]) -> void:
	var health = GlobalHealth.get_health_instance()
	health.apply_shield(shield_amount)
