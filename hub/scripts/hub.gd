extends Node2D
class_name Hub

#@onready var player: Player = $Player
var player: Player

@export var char_stats: CharStats
@export var player_spawn_position: Vector2 = Vector2(1400, 180)

func _ready():
	var player_instance = preload("res://player/player.tscn").instantiate()
	add_child(player_instance)
	player = player_instance
	player.global_position = player_spawn_position
	





func _on_area_2d_body_entered(body: Node2D) -> void:
	$LeaveHubView/LeaveHubScreen.visible = true
	get_tree().paused = true


func _on_add_pressed() -> void:
	Money.add_money(1)


func _on_subtract_pressed() -> void:
	Money.subtract_money(1)
