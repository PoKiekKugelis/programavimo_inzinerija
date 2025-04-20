extends Node
class_name EnemyAction

enum Type {CONDITIONAL, CHANCE_BASED}

@export var type: Type
@export_range(0.0, 10.0) var chance_weight := 0.0

@onready var accumulated_weight := 0.0

var enemy: TestEnemy
var target: Node2D
var intent: String
var message: String

func is_performable() -> bool:
	return false


func perform_action() -> void:
	pass
