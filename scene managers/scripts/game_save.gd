extends Node
class_name GameSave

#aprašytos scenas, kurias turės inicializuoti GameSave mazgas
const HUB:= preload("res://hub/scenes/hub.tscn")#pasirinkus save'ą galima eiti į hub'ą
const RUN:= preload("res://scene managers/scenes/run.tscn")#pasirinkus save'ą galima eiti tiesiai į run'ą

@onready var current_view: Node = $CurrentView

#globalūs kintamieji
#inventory Dar į inventorių dėti tik permanent items pvz resursus, nes jis global? ateities problema. Gal reikės jį pakeisti iš global ir čia sukurti 2 inventorius
#money irgi global tai iš vis dzin
#resources kažkokie
var health: Health = Health.new()
var stamina: Stamina = Stamina.new()
var character: CharStats
var starting_health_value: int = 10
var starting_stamina_value: int = 100
#galima stamina, health, resources sudėti į charStats, gal būtų paprasčiau idk, bet veiklos nemažai atrodo

func _ready() -> void:
	#priklausomai nuo save'o reikės, kad čia pasijungtų kas reikia, bet ateities problema.
	var base_player := load("res://player/base_player.tres")
	character = base_player.create_instance()
	initialize_health_stamina()
	add_node_resources()
	start_game()

func start_game() -> void:
	on_hub_entered()#čia save states kažkur įeina galvočiau, nes nebūtina, kad visada startintų su HUB bet I digress, nieko neišmanau apie saves
	setup_event_connections()

func initialize_health_stamina() -> void:# Kiekvieną kartą pradeda su starting hp ir stamina
	stamina.max_stamina = starting_stamina_value
	stamina.stamina = starting_stamina_value
	health.set_max_health(starting_health_value)
	health.set_health(starting_health_value)

func add_node_resources() -> void:# Vaikams health ir stamina duodu tėvą. To reikia, nes kitaip prisidarys daugybė orphans
	# ir reikės juos atskirai trinti. Nes kai baigiasi run, jis išsitrina (Hub pakeičia jo vietą) ir taip visus
	# vaikus ištrina. Jei tie health ir stamina yra orphans, jie lieka amžinai ir kitą run'ą pradėsi su tokiu hp
	# kokiu pradėjai paskutinį run'ą
	self.add_child(health)
	self.add_child(stamina)

func change_view(scene: PackedScene) -> Node:# Keičia CurrentView vaiką į duotą ir ištrina praeitą
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	var new_view = scene.instantiate()
	current_view.add_child(new_view)
	return new_view

func setup_event_connections() -> void:
	#čia visi signalai go crazy .connect() vietoj change_scene_to_file beveik visur išskyrus aukščiausią lygį
	# Sujungia signalus, kuriuos galima bet kur bet kada iškviesti, kai nori 
	# pakeisti į tam tikrą sceną. Preload viršuj sceną, tada Events sukuri signalą, jei ta scena dar neturi signalo 
	# arba reikia, kad eitų į tą pačią sceną ir šiuo momentu skirtumo nėra, bet ateity bus (restart_at_hub ir run_ended)
	Events.start_run.connect(on_run_entered)
	Events.restart_at_hub.connect(on_hub_entered)
	Events.run_ended.connect(on_hub_entered)

func on_hub_entered() -> void:# Hub scena pridedama kaip dabartinis vaizdas
	SaveSystem.load_game()
	var hub_scene: Hub = change_view(HUB) as Hub
	hub_scene.player.char_stats = character
	change_player_health_stamina(hub_scene)

func on_run_entered() -> void:# Run scena pakeičiama kaip dabartinis vaizdas vietoj praeitos (hub)
	Inventory.clear() # Run pradedi su tusciu inventorium
	var run_scene: Run = change_view(RUN) as Run
	run_scene.character = character
	change_scene_health_stamina(run_scene)
	run_scene.start_run()

func change_player_health_stamina(scene) -> void:# for the nodes which have players aka hub
	# Ιš GameSavo'o priskiria būtent hp ir stamina į scenos player
	scene.player.health.set_max_health(health.max_health)
	scene.player.health.set_health(health.health)
	scene.player.stamina.max_stamina = stamina.max_stamina
	scene.player.stamina.stamina = stamina.stamina
	scene.player.connect_deck()

func change_scene_health_stamina(run) -> void:# For the Run node
	# Ιš GameSavo'o priskiria būtent hp ir stamina į sceną. Šiuo atveju tai naudoja tik run.
	# Šito gali reikėti ir run script'e, kad galėtų perduoti run'o metu gautus permanent upgrades
	run.health.set_max_health(health.max_health)
	run.health.set_health(health.health)
	run.stamina.max_stamina = stamina.max_stamina
	run.stamina.stamina = stamina.stamina
