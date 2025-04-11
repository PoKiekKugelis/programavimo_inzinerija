extends HBoxContainer
class_name Hand

@export var char_stats: CharStats
@onready var card_ui := preload("res://cards/scenes/card_ui.tscn")
var cards_played_this_turn = 0
func _ready() -> void:
	Events.card_played.connect(on_card_played)

func on_card_played() -> void:
	cards_played_this_turn += 1

func discard_card(card: CardUI) -> void:
	card.queue_free()

func disable_hand() -> void:
	for card in  get_children():
		card.disabled = true

func add_card(card: Card) -> void:
	var new_card_ui := card_ui.instantiate() as CardUI
	add_child(new_card_ui)
	new_card_ui.reparent_requested.connect(on_card_ui_reparent_requested)
	new_card_ui.card = card
	new_card_ui.parent = self
	new_card_ui.char_stats = char_stats

func on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
	var new_index := clampi(child.original_index, 0, get_child_count())
	move_child.call_deferred(child, new_index)
