extends Node2D

@onready var player: Player = %Player
@export var player_spawn_position: Vector2 = Vector2(100, 100)

func _ready() -> void:
	add_player()
	load_data()

func add_player() -> void:
	var player_instance = preload("res://player/player.tscn").instantiate()
	add_child(player_instance)
	player = player_instance
	player.global_position = player_spawn_position

#idk su _ready tik 1 pirma karta suveikia
func _enter_tree() -> void:
	load_data()

# loads player data from the save system
func load_data():
	var player = find_child("Player", true, false)
	# if we found a Player node AND it has a Health child node set player's health from saved data with fallback to max health
	if player and player.has_node("Health"):
		player.health.set_health(SaveSystem.load_game().get("Health", player.health.max_health))
