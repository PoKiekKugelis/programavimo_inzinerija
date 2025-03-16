extends Control
class_name CardUI

signal reparent_requested(whicih_card_ui: CardUI)

@export var card: Card : set = _set_card
@onready var texture_rect: TextureRect = $TextureRect
@onready var cost: Label = $TextureRect/Panel/Cost

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	card = value
	cost.text = str(card.cost)
	texture_rect.texture = card.icon
