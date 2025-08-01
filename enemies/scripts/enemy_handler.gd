extends Node2D
class_name EnemyHandler

func _ready() -> void:
	Events.enemy_action_completed.connect(_on_enemy_action_completed)

func reset_enemy_actions() -> void:
	for enemy: TestEnemy in get_children():
		enemy.current_action = null
		enemy.update_action()

func start_turn() -> void:
	if get_child_count() == 0:
		return
	var first_enemy: TestEnemy = get_child(0) as TestEnemy
	first_enemy.do_turn()

func _on_enemy_action_completed(enemy: TestEnemy) -> void:
	if enemy.get_index() == get_child_count() - 1:
		Events.enemy_turn_ended.emit()
		return
	var next_enemy: TestEnemy = get_child(enemy.get_index()+1) as TestEnemy
	next_enemy.do_turn()
