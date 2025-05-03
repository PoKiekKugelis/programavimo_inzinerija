extends CenterContainer
class_name CardMenuUI

signal tooltip_requested(card: Card)

#const BASE_STYLEBOX := preload()
@export var card: Card : set = set_card
@onready var texture: TextureRect = $Visuals/TextureRect
@onready var cost: Label = $Visuals/TextureRect/Cost

func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	cost.text = str(card.cost)
	texture.texture = card.icon

func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		tooltip_requested.emit(card)
