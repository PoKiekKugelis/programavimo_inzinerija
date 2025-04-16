extends Node2D
class_name LevelScene

@onready var deck_button: CardDeckOpen = %DeckButton
@onready var deck_view: CardDeckView = $CardDeckView/DeckView
@onready var camera: Camera2D = $Player/Camera2D
@onready var player: Player = %Player

@export var char_stats: CharStats
#vietoj to kad pilnai pakeist scena, tiesiog instantiate naudojuj, nes change_scene
#neissaugotu dabartines map state, tai todel tiesiog pauze padarau
#(teoriskai turbut butu galima combat scena kaip child pridet, bet idk, kolkas veikia)
#dar turbut reiketu isskaidyt i mazesnius metodus, kad readability butu geresnis
#krc nezinau kas cia vyksta
# skull emoji 💀
func _ready() -> void:
	load_data()
	connect_deck()#iškviečia, kad prijungtų on ready decką
	var health_node = $Player/Health
	GlobalHealth.set_health_instance(health_node) # connect the health, so the visual of the health bar is full and goes down when taking damage
	player.stats = char_stats

#idk su _ready tik 1 pirma karta suveikia
func _enter_tree() -> void:
	load_data()

#tikisuo sita 1 eilute yra visiem suprantama
func load_data():
	get_child(2).get_child(0).health = SaveSystem.load_game().get("Health", get_child(2).get_child(0).max_health)

func connect_deck():
	deck_button.card_deck = preload("res://cards/card types/starting_deck.tres")#prijungia pradinę kaladę, kad žinotu kiek kortų turi
	deck_view.card_deck = preload("res://cards/card types/starting_deck.tres")#prijungia kaladę, kad žinotų, kokias kortas rodyti
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))#prijungia kaip mygtuką
	#bet reikės pridėti, kad hover pakeistų spalvą truputį ar kažką, kad aiškiau būtų
