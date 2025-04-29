extends Node2D

@onready var player: Player = %Player
@export var player_spawn_position: Vector2 = Vector2(400, 470)

func _ready() -> void:
	add_player()

func add_player() -> void:
	var player_instance = preload("res://player/player.tscn").instantiate()
	add_child(player_instance)
	player = player_instance
	player.global_position = player_spawn_position
