extends Control

func _on_no_pressed() -> void:
	get_tree().paused = false
	$".".visible = false


func _on_yes_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game scenes/game.tscn")

func _input(event: InputEvent) -> void:
	if $".".visible and event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		$".".visible = false
