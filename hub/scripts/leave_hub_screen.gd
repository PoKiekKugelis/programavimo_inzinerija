extends Control

@export var run_startup: RunStartup

func _on_no_pressed() -> void:
	get_tree().paused = false
	$".".visible = false

func _on_yes_pressed() -> void:
	get_tree().paused = false
	sync_character()
	Events.start_run.emit()

func _input(event: InputEvent) -> void:
	if $".".visible and event.is_action_pressed("ui_cancel"):
		get_tree().paused = false
		$".".visible = false

func sync_character() -> void:
	var game_save: GameSave = get_tree().root.get_child(-1)
	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.character_setup = game_save.character
