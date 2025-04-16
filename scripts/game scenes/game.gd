extends Node2D
class_name LevelScene

@onready var deck_button: CardDeckOpen = %DeckButton
@onready var deck_view: CardDeckView = $CardDeckView/DeckView
@onready var camera: Camera2D = $Player/Camera2D
@onready var player: Player = %Player

@export var instance = null
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
	Events.in_combat_status_changed.connect(_on_game_in_combat_status_changed)# combat ended signal
	player.stats = char_stats

func _on_game_in_combat_status_changed() -> void:
	Events.in_combat = !Events.in_combat

#idk su _ready tik 1 pirma karta suveikia
func _enter_tree() -> void:
	load_data()

#tikisuo sita 1 eilute yra visiem suprantama
func load_data():
	get_child(2).get_child(0).health = SaveSystem.load_game().get("Health", get_child(2).get_child(0).max_health)

func _on_player_enter_combat(enemy: CharacterBody2D) -> void:
	Events.in_combat_status_changed.emit()#naudojamas pause screen, kad neisjungtu pauzes esant in combat
	$PauseScreenView/PauseScreen.z_index = 10
	var combat_scene: PackedScene = preload("res://combat/scenes/combat_screen.tscn")
	var combat_instance = combat_scene.instantiate()
	var playerSprite = $Player/AnimatedSprite2D.duplicate()
	var combat_enemy = enemy.duplicate() # the whole enemy is taken instead of the sprite
	combat_instance.enemy = combat_enemy
	var new_stats: CharStats = char_stats.create_instance()
	combat_instance.char_stats = new_stats
	combat_instance.add_child(playerSprite) # add player character to combat
	combat_instance.add_child(combat_enemy) # add enemy instance to combat (using duplicated version)
	combat_instance.player = playerSprite
	instance = combat_instance
	get_tree().paused = true
	get_parent().add_child(combat_instance)

func connect_deck():
	deck_button.card_deck = preload("res://cards/card types/starting_deck.tres")#prijungia pradinę kaladę, kad žinotu kiek kortų turi
	deck_view.card_deck = preload("res://cards/card types/starting_deck.tres")#prijungia kaladę, kad žinotų, kokias kortas rodyti
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))#prijungia kaip mygtuką
	#bet reikės pridėti, kad hover pakeistų spalvą truputį ar kažką, kad aiškiau būtų

func _on_pause_screen_quit_while_in_combat() -> void:
	instance.free()
	get_tree().paused = false
