extends Node

@onready var complete_sound: AudioStreamPlayer2D = $CompleteSound


func _ready() -> void:
	complete_sound.play()

func _on_return_pressed():
	SaveSystem.save_game()
	Events.restart_at_hub.emit()

func _on_main_menu_pressed():
	SaveSystem.save_game()
	get_tree().change_scene_to_file("res://scenes/game scenes/main_menu.tscn")
