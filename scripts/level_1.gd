extends Node2D

func _ready() -> void:
	load_data()

#tikisuo sita 1 eilute yra visiem suprantama
func load_data():
	get_child(1).get_child(0).health = SaveSystem.load_game().get("Health", get_child(1).get_child(0).max_health)
