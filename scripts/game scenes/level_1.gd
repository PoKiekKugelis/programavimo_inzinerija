extends Node2D

@onready var deck_button: CardDeckOpen = %DeckButton
@onready var deck_view: CardDeckView = $CardDeckView/DeckView

func _ready() -> void:
	load_data()
	$Player/Camera2D.make_current()
	connect_deck()
	var health_node = $Player/Health
	GlobalHealth.set_health_instance(health_node) # connect the health, so the visual of the health bar is full and goes down when taking damage

#tikisuo sita 1 eilute yra visiem suprantama
func load_data():
	get_child(2).get_child(0).health = SaveSystem.load_game().get("Health", get_child(2).get_child(0).max_health)


func connect_deck():
	deck_button.card_deck = preload("res://cards/card types/starting_deck.tres")#prijungia pradinę kaladę, kad žinotu kiek kortų turi
	deck_view.card_deck = preload("res://cards/card types/starting_deck.tres")#prijungia kaladę, kad žinotų, kokias kortas rodyti
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))#prijungia kaip mygtuką, bet reikės
	#pridėti, kad hover pakeistų spalvą truputį ar kažką, kad aiškiau būtų
