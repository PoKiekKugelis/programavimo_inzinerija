extends Node2D

func _ready() -> void:
	# Connect button signal
	$Continue.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Return to the main game
	get_tree().paused = false
	queue_free()
	
	# Emit a signal that the parent can connect to
	# You'll need to define this signal at the top of the script
	emit_signal("continue_game")
