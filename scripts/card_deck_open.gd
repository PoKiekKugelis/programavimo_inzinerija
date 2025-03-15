extends TextureButton
class_name CardDeckOpen

@export var counter: Label
@export var card_deck: CardDeck : set = set_card_deck

func set_card_deck(new_value: CardDeck) -> void:
	card_deck = new_value
	if not card_deck.card_deck_size_changed.is_connected(_on_card_deck_size_changed):
		card_deck.card_deck_size_changed.connect(_on_card_deck_size_changed)
		_on_card_deck_size_changed(card_deck.cards.size())

func _on_card_deck_size_changed(cards_amount: int) -> void:
	counter.text = str(cards_amount)
