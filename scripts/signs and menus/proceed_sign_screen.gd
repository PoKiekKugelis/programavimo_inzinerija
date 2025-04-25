extends Control


func _input(event: InputEvent) -> void:
	if $".".visible and event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		$".".visible = false


func _on_go_to_hub_pressed() -> void:
	get_tree().paused = false
	Events.run_ended.emit()


func _on_proceed_pressed() -> void:
	get_tree().paused = false
	Events.changing_level.emit()
	Events.run_continues.emit()
