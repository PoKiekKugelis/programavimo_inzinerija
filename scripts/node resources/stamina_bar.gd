extends TextureProgressBar

@onready var stamina: Stamina = owner.get_parent().get_node("Player/Stamina")  


func _ready() -> void:
	setup_stamina_bar()

func setup_stamina_bar():
	max_value = stamina.max_stamina
	value = stamina.stamina
	
	if stamina.stamina_changed.is_connected(_update_bar):
		stamina.stamina_changed.disconnect(_update_bar)
	stamina.stamina_changed.connect(_update_bar)

func _update_bar() -> void:
	value = stamina.stamina
