extends Resource
class_name CharStats

signal stats_changed

@export var starting_deck: CardDeck
@export var cards_per_turn: int
@export var max_energy: int

var energy: int : set = set_energy
var deck: CardDeck
var draw_deck: CardDeck
var discard: CardDeck

func set_energy(value: int) -> void:
	energy = value
	stats_changed.emit()

func reset_energy() -> void:
	self.energy = max_energy

func can_play_card(card: Card) -> bool:
	return energy >= card.cost

func create_instance() -> Resource:
	var instance : CharStats = self.duplicate()
	instance.reset_energy()
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_deck = CardDeck.new()
	instance.discard = CardDeck.new()
	return instance
