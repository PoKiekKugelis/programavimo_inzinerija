extends Control

#var target_scene = "res://scenes/game.tscn" #path of main game scene
var target_scene = "res://saves/scenes/load_screen.tscn" #path of load screen


func _ready() -> void:
	$ButtonContainer/Start.grab_focus()

func _on_start_pressed():
	get_tree().change_scene_to_file(target_scene) #Simply changes the scene

func _on_quit_pressed():
	get_tree().quit() #Simply closes the game 
