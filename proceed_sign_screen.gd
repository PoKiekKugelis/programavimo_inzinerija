extends Control


func _input(event: InputEvent) -> void:
	if $".".visible and event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		$".".visible = false


func _on_go_to_hub_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/hub.tscn")


func _on_proceed_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level1.tscn")
