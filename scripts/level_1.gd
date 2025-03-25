extends Node2D

@onready var deck_button: CardDeckOpen = %DeckButton
@onready var deck_view: CardDeckView = $CardDeckView/DeckView

func _ready() -> void:
	$Player/Camera2D.make_current()
	connect_deck()

func connect_deck():
	deck_button.card_deck = preload("res://cards/starting_deck.tres")#prijungia pradinę kaladę, kad žinotu kiek kortų turi
	deck_view.card_deck = preload("res://cards/starting_deck.tres")#prijungia kaladę, kad žinotų, kokias kortas rodyti
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))#prijungia kaip mygtuką, bet reikės
	#pridėti, kad hover pakeistų spalvą truputį ar kažką, kad aiškiau būtų
