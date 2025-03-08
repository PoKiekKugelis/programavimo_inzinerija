extends Node


func _on_return_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
