extends Node2D

@export var force = -600.0
@onready var pad_sound: AudioStreamPlayer2D = $PadSound



func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body is Player:
		body.velocity.y = force
		pad_sound.play()
