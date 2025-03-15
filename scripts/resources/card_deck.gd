extends Resource

class_name CardDeck

signal card_deck_size_changed(cards_amount)

@export var cards: Array[Card] = []


func empty() -> bool:
	return cards.is_empty()

func draw_card() -> Card:
	var card = cards.pop_front()
	card_deck_size_changed.emit(cards.size())
	return card

func shuffle() -> void:
	cards.shuffle()

func add_card(card: Card) -> void:
	cards.append(card)
	card_deck_size_changed.emit(cards.size())

func clear() -> void:
	cards.clear()
	card_deck_size_changed.emit(cards.size())
