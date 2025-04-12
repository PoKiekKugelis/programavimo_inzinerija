extends Node


func _on_return_pressed():
	get_tree().change_scene_to_file("res://hub/scenes/hub.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/game scenes/main_menu.tscn")
