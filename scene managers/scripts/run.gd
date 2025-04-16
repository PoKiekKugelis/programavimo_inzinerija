extends Node
class_name Run

#apsirašyti  visas scenas, kurias inicializuos run mazgas
const LEVEL_SCENE:= preload("res://scenes/game scenes/game.tscn")
const LEVEL_SCENE2:= preload("res://scenes/game scenes/level1.tscn")
const COMBAT_SCENE:= preload("res://combat/scenes/combat_screen.tscn")
const RUN_COMPLETE:= preload("res://scenes/game scenes/level_complete.tscn")
const PLAYER_DEATH:= preload("res://scenes/game scenes/death_screen.tscn")#numirus nebe change current scene, o per signals atsiųsti čia, kad pakeistų sceną

@export var run_startup: RunStartup

@onready var current_view: Node = $CurrentView

#kintamieji run'ui, čia daugiau bus arba į vieną character viskas sudėta
var character : CharStats
var health: Health = Health.new()
var stamina: Stamina = Stamina.new()

var level_scene

func _ready() -> void:
	add_node_resources()
	if not run_startup:
		return
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			character = run_startup.character_setup.create_instance()
			start_run()
		RunStartup.Type.CONTINUED_RUN:#set character to the one received from GameSave or smth
			print("TODO: load previous run")

func start_run() -> void:
	on_level_entered()
	setup_event_connections()

func change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	var new_view = scene.instantiate()
	current_view.add_child(new_view)
	return new_view

func setup_event_connections() -> void:
	Events.run_won.connect(change_view.bind(RUN_COMPLETE))
	Events.player_died.connect(change_view.bind(PLAYER_DEATH))
	Events.updated_run_variables.connect(update_player.bind(level_scene))
	Events.changing_level.connect(update_run.bind(level_scene))
	Events.run_continues.connect(on_level_entered2)

func on_level_entered() -> void:
	level_scene = change_view(LEVEL_SCENE)

func on_level_entered2() -> void:
	level_scene = change_view(LEVEL_SCENE2)
	update_player(level_scene)

func update_player(scene) -> void:
	scene.char_stats = character
	scene.player.stats = character
	change_health_stamina(scene)
	scene.get_node("Player/HealthBar").setup_health_bar(scene.player.health)
	scene.get_node("Player/StaminaBar").setup_stamina_bar()

func update_run(scene) -> void:
	character = scene.char_stats
	health.set_max_health(scene.player.health.max_health)
	health.set_health(scene.player.health.health)
	stamina.max_stamina = scene.player.stamina.max_stamina
	stamina.stamina = scene.player.stamina.stamina

func change_health_stamina(scene) -> void:
	scene.player.health.set_max_health(health.max_health)
	scene.player.health.set_health(health.health)
	scene.player.stamina.max_stamina = stamina.max_stamina
	scene.player.stamina.stamina = stamina.stamina

func add_node_resources() -> void:
	self.add_child(health)
	self.add_child(stamina)
