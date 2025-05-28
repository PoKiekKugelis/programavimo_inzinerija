extends TestEnemy
class_name BossEnemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy")
	animated_sprite = animated_sprite_2d
	health = $Health
	health.health_depleted.connect(_on_death)
