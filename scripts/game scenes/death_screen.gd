extends Node


func _ready() -> void:
	SaveSystem.delete_data()
	if Events.in_combat:
		Events.in_combat_status_changed.emit()


func _on_restart_pressed() -> void:
	Events.restart_at_hub.emit()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game scenes/main_menu.tscn")
