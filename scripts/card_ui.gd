extends Control
class_name CardUI

signal reparent_requested(which_card_ui: CardUI)

@export var card: Card : set = set_card
@export var char_stats: CharStats : set = set_char_stats

@onready var texture_rect: TextureRect = $TextureRect
@onready var cost: Label = $TextureRect/Panel/Cost

func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	card = value
	cost.text = str(card.cost)
	texture_rect.texture = card.icon

func set_char_stats(value: CharStats) -> void:
	char_stats = value
	char_stats.stats_changed.connect(on_char_stats_changed)

func on_char_stats_changed() -> void:
	self.playable = char_stats.can_play_card(card)
