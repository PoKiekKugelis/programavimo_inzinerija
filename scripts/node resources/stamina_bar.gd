extends TextureProgressBar

@onready var stamina: Stamina = owner.find_child("Stamina")  


func _ready() -> void:
	setup_stamina_bar()

func setup_stamina_bar():
	max_value = stamina.max_stamina
	value = stamina.stamina
	stamina.stamina_changed.connect(_update_bar)

func _update_bar() -> void:
	value = stamina.stamina
