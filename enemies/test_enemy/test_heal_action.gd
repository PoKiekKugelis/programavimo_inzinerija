extends EnemyAction

@export var heal := 2


func _ready() -> void:
	message = "[color=green]Enemy healed %d health[/color]" % heal

func perform_action() -> void:
	var time = 0.6
	if not enemy or not target:
		return
	var anim_sprite = enemy.get_node("AnimatedSprite2D") as AnimatedSprite2D
	var heal_effect := DamageEffect.new()
	heal_effect.amount = heal
	heal_effect.heal([enemy])
	if enemy is BossEnemy:
		time = 2
		anim_sprite.sprite_frames.set_animation_loop("heal", false)
		anim_sprite.play("heal")
	get_tree().create_timer(time).timeout.connect(
		func():
			anim_sprite.play("idle")
			Events.enemy_action_completed.emit(enemy)
	)
