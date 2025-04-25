extends Node
class_name player_manager
var player: Player = null

func register_player(new_player: Player) -> void:
	if player != null:
		player.queue_free()
	player = new_player
	player.set_meta("persist", true)
