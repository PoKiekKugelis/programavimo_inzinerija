extends Node2D

@onready var deck_button: CardDeckOpen = %DeckButton
@onready var deck_view: CardDeckView = $CardDeckView/DeckView
@onready var camera: Camera2D = $Player/Camera2D

#naudojamas pause screen, kad neisjungtu pauzes esant in combat
signal in_combat_status_changed()

@export var instance = null

#vietoj to kad pilnai pakeist scena, tiesiog instantiate naudojuj, nes change_scene
#neissaugotu dabartines map state, tai todel tiesiog pauze padarau
#(teoriskai turbut butu galima combat scena kaip child pridet, bet idk, kolkas veikia)
#dar turbut reiketu isskaidyt i mazesnius metodus, kad readability butu geresnis
#krc nezinau kas cia vyksta
# skull emoji 💀
func _ready() -> void:
	connect_deck()#iškviečia, kad prijungtų on ready decką
	var health_node = $Player/Health
	GlobalHealth.set_health_instance(health_node) # connect the health, so the visual of the health bar is full and goes down when taking damage

func _on_player_enter_combat(enemy: CharacterBody2D) -> void:
	
	
	emit_signal("in_combat_status_changed")
	$PauseScreenView/PauseScreen.z_index = 10
	#pauze dabar bus virs combat scenos (tik vizualiai, migtukus galima su keyboard valdyt)
	#taciau siuo metu kai pauze ijungta combat vistiek gali bagitis (kas ir ivyksta po 5 sekundziu) 
	#ir tai isjungia pauze esant pauzes scenai aktyviai,
	#cia nedidele problema, nes tikro zaidimo metu, kova nelabai gales 
	#baigtis esant pauzej, nebent ijungi pauze viduri final hit atakos animacijos, tada turbut reiketu
	#patikrint ar pauze ijungta ir priklausomai isjungti tree pauze
	#arba tiesiog padaryt, kad combat reward popup langas pratestu pauze (vyktu pauzes metu)
	var combat_scene: PackedScene = preload("res://combat/combat_screen.tscn")
	var combat_instance = combat_scene.instantiate()
	var player = $Player/Sprite2D.duplicate()
	#var enemySprite = enemy.get_child(2).duplicate() #pasiemu animated sprite
	var combat_enemy = enemy.duplicate() # the whole enemy is taken instead of the sprite
	#combat_enemy.position = Vector2(900, 500) # Manually place enemy in combat scene
	combat_instance.enemy = combat_enemy
	#veliau turbut reiketu pati enemy pasiimt, bet kad nuo map nenukristu padaryt
	#kai bus imamas pats enemy, tai tada turbut reikes jo direction uzrakint ir uzdet idle animation
	combat_instance.add_child(player) # add player character to combat
	#combat_instance.add_child(enemySprite)
	combat_instance.add_child(combat_enemy) # add enemy instance to combat (using duplicated version)
	combat_instance.player = player
	combat_instance.player.visible = false # hide player sprite initially (may be revealed later)
	#combat_instance.enemy = enemySprite
	combat_instance.enemy.visible = true 
	instance = combat_instance
	get_tree().paused = true
	get_tree().root.add_child(combat_instance)
	#dabar po penkiu sekundziu tiesiog panaikinu combat scena ir priesa ir atminties
	#poto kai bus combat, tai speju su signalais bus galima kazkaip padaryt 
	#kad on_victory and on_defeat tam tikrus dalykus padaryt
	#await get_tree().create_timer(5).timeout
	#combat_instance.free()
	#$Player/Camera2D.make_current()
	#get_tree().paused = false
	#emit_signal("in_combat_status_changed")

func connect_deck():
	deck_button.card_deck = preload("res://cards/starting_deck.tres")#prijungia pradinę kaladę, kad žinotu kiek kortų turi
	deck_view.card_deck = preload("res://cards/starting_deck.tres")#prijungia kaladę, kad žinotų, kokias kortas rodyti
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))#prijungia kaip mygtuką, bet reikės
	#pridėti, kad hover pakeistų spalvą truputį ar kažką, kad aiškiau būtų

func _on_pause_screen_quit_while_in_combat() -> void:
	instance.free()
	get_tree().paused = false
