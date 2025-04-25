extends Node

@onready var button: Button = $Button

func _ready() -> void:
	# Connect button signal
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Return to the main game
	get_tree().paused = false
	Events.in_combat_status_changed.emit()
	get_parent().get_parent().queue_free()
	
	# Emit a signal that the parent can connect to
	# You'll need to define this signal at the top of the script
	emit_signal("continue_game")
