extends TextureProgressBar

@export var character: CharacterBody2D

@onready var stamina: Stamina = character.find_child("Stamina")  


func _ready() -> void:
	max_value = stamina.max_stamina
	value = stamina.stamina
	stamina.stamina_changed.connect(_update_bar)


func _update_bar() -> void:
	value = stamina.stamina
