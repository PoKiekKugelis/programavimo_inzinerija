extends Node
class_name GameSave

#aprašytos scenas, kurias turės inicializuoti GameSave mazgas
const HUB:= preload("res://hub/scenes/hub.tscn")#pasirinkus save'ą galima eiti į hub'ą
const RUN:= preload("res://scene managers/scenes/run.tscn")#pasirinkus save'ą galima eiti tiesiai į run'ą

@onready var current_view: Node = $CurrentView

#globalūs kintamieji
#inventory Dar į inventorių dėti tik permanent items pvz resursus, nes jis global? ateities problema
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
	on_hub_entered()#čia save states kažkur įeina galvočiau, nes nebūtina, kad visada startintų su HUB
	setup_event_connections()

func initialize_health_stamina() -> void:
	stamina.max_stamina = starting_stamina_value
	stamina.stamina = starting_stamina_value
	health.set_max_health(starting_health_value)
	health.set_health(starting_health_value)

func change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	var new_view = scene.instantiate()
	current_view.add_child(new_view)
	return new_view

func setup_event_connections() -> void:
	#čia visi signalai go crazy .connect() vietoj change_scene_to_file beveik visur išskyrus aukščiausią lygį
	Events.start_run.connect(on_run_entered)
	Events.restart_at_hub.connect(on_hub_entered)
	Events.run_ended.connect(on_hub_entered)

func on_hub_entered() -> void:
	var hub_scene: Hub = change_view(HUB) as Hub
	hub_scene.char_stats = character
	hub_scene.player.stats = character
	change_player_health_stamina(hub_scene)

func on_run_entered() -> void:# Run scena pakeičiama kaip dabartinis vaizdas su praeita buvusia (hub)
	var run_scene: Run = change_view(RUN) as Run#durnas dalykas, nes Run scena viską pirmiau padaro ir tik tada šitas 3 eilutes įvykdo aka run scena be health ir stamina ir character reišmių važiuoja toliau
	run_scene.character = character
	change_scene_health_stamina(run_scene)
	Events.updated_run_variables.emit()#Todėl perdavus duomenis iš karto be signalo viskas būtų 0. Čia palaukiu, kol run scena turi visus duomenis apie health ir stamina ir tada juos priskiria game scenai

func change_player_health_stamina(scene) -> void:# for the nodes which have players aka hub and all the levels
	scene.player.health.set_max_health(health.max_health)
	scene.player.health.set_health(health.health)
	scene.player.stamina.max_stamina = stamina.max_stamina
	scene.player.stamina.stamina = stamina.stamina

func change_scene_health_stamina(scene) -> void:# For the Run node
	scene.health.set_max_health(health.max_health)
	scene.health.set_health(health.health)
	scene.stamina.max_stamina = stamina.max_stamina
	scene.stamina.stamina = stamina.stamina

func add_node_resources() -> void:
	self.add_child(health)
	self.add_child(stamina)
