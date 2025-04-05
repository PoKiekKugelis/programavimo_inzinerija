extends Node
class_name PlayerHandler

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var hand: Hand

var character: CharStats

func _ready() -> void:
	Events.card_played.connect(on_card_played)
	
func start_battle(char_stats: CharStats) -> void:
	character = char_stats
	character.draw_deck = character.deck.duplicate(true)
	character.draw_deck.shuffle()
	character.discard = CardDeck.new()
	start_turn()

func start_turn() -> void:
	character.reset_energy()
	draw_cards(character.cards_per_turn)

func end_turn() -> void:
	#hand.disable_hand()
	discard_cards()

func draw_card() -> void:
	reshuffle_deck_from_discard()
	hand.add_card(character.draw_deck.draw_card())
	reshuffle_deck_from_discard()

func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit()
	)

func discard_cards() -> void:
	var tween := create_tween()
	for card_ui in hand.get_children():
		tween.tween_callback(character.discard.add_card.bind(card_ui.card))
		tween.tween_callback(hand.discard_card.bind(card_ui))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	tween.finished.connect(
		func(): Events.player_hand_discarded.emit()
	)

func reshuffle_deck_from_discard() -> void:
	if not character.draw_deck.empty():
		return
	while not character.discard.empty():
		character.draw_deck.add_card(character.discard.draw_card())
	
	character.draw_deck.shuffle()

func on_card_played(card: Card) -> void:
	character.discard.add_card(card)
