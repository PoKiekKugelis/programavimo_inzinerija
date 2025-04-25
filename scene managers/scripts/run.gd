extends Node
class_name Run

#apsirašyti  visas scenas, kurias inicializuos run mazgas
const LEVEL_SCENE:= preload("res://scenes/game scenes/game.tscn")
const LEVEL_SCENE2:= preload("res://scenes/game scenes/level1.tscn")
const COMBAT_SCENE:= preload("res://combat/scenes/combat_screen.tscn")
const RUN_COMPLETE:= preload("res://scenes/game scenes/level_complete.tscn")
const PLAYER_DEATH:= preload("res://scenes/game scenes/death_screen.tscn")#numirus nebe change current scene, o per signals atsiųsti čia, kad pakeistų sceną

@export var run_startup: RunStartup# Čia saugo character duomenis ir ar New run ar continued. Leave_hub_screen naudojama
# Galimai nelabai reikalinga. Čia buvo mano first attempt at perkelti duomenis, bet supratau, kad nodes negalima
# per resursą (run_startup) perkelti. Todėl galvojau keisti Health ir Stamina į resources, bet tas truputį cringe,
# gal ateitį. Tai jis čia gal sueitų sekimui tsg character

@onready var current_view: Node = $CurrentView# Kadangi turim nodes resursus, kad jie nebūtų orphans reikia juos į
# medį pridėti - tėvą duoti. Tai dabartinę sceną pridedu ant šito node, kad galėčiau tikrinti, kad tik vienas node 
# pridėtas būtų keitimo metu.

#kintamieji run'ui, čia daugiau bus arba į vieną character viskas sudėta
var character : CharStats
# Va sukuriu vaikus orphans
var health: Health = Health.new()
var stamina: Stamina = Stamina.new()

var level_scene# čia lygį dabartinį saugau kaip mazgą (pvz. Game sceną visą).
# Pasibaigus level'iui iš šito būtent kintamojo perrimu visą player info ir run'ui atiduodu update_run metode.

func _ready() -> void:
	add_node_resources()
	if not run_startup:
		return
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			character = run_startup.character_setup.create_instance()# čia tas RunStartup priskiria character, bet aš tą jau padarau vėliau irgi
			start_run()
		RunStartup.Type.CONTINUED_RUN:#set character to the one received from GameSave or smth
			print("TODO: load previous run")

func start_run() -> void:
	on_first_level_entered()
	setup_event_connections()

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

func setup_event_connections() -> void:# Sujungia signalus, kuriuos galima bet kur bet kada iškviesti, kai nori 
	# pakeisti į tam tikrą sceną. Preload viršuj sceną, tada Events sukuri signalą, jei ta scena dar neturi signalo 
	# arba reikia, kad eitų į tą pačią sceną ir šiuo momentu skirtumo nėra, bet ateity bus
	Events.run_won.connect(change_view.bind(RUN_COMPLETE))
	Events.player_died.connect(change_view.bind(PLAYER_DEATH))
	Events.updated_run_variables.connect(update_player.bind(level_scene))
	Events.changing_level.connect(update_run.bind(level_scene))
	Events.run_continues.connect(on_level_entered)
	Events.enter_combat.connect(_on_player_enter_combat)
	Events.in_combat_status_changed.connect(_on_game_in_combat_status_changed)# combat ended signal

func on_first_level_entered() -> void:# Būtų vienas on_level_entered, bet pirmą kartą jis greičiau update_player
	# padaro nei GameSave sugeba jam duomenis perduoti, tdl laukiam signalo updated_run_variables pirmą kartą
	level_scene = change_view(LEVEL_SCENE)

func on_level_entered() -> void:# Antrą ir visus kitus jau važiuojam iš karto update_player
	level_scene = change_view(LEVEL_SCENE2)
	update_player(level_scene)

func update_player(scene) -> void:# Ιš run'o priskiria duomenis į scenos player
	scene.char_stats = character
	scene.player.stats = character
	change_player_health_stamina(scene)
	scene.get_node("Player/HealthBar").setup_health_bar(scene.player.health)
	scene.get_node("Player/StaminaBar").setup_stamina_bar()

func update_run(scene) -> void:# Ιš scenos player priskiria duomenis į run'ą 
	character = scene.char_stats
	health.set_max_health(scene.player.health.max_health)
	health.set_health(scene.player.health.health)
	stamina.max_stamina = scene.player.stamina.max_stamina
	stamina.stamina = scene.player.stamina.stamina

func change_player_health_stamina(scene) -> void:# for the nodes which have players aka game/level1
	# Ιš run'o priskiria būtent hp ir stamina į scenos player
	scene.player.health.set_max_health(health.max_health)
	scene.player.health.set_health(health.health)
	scene.player.stamina.max_stamina = stamina.max_stamina
	scene.player.stamina.stamina = stamina.stamina

func _on_player_enter_combat(enemy: CharacterBody2D) -> void:
	Events.in_combat_status_changed.emit()#naudojamas pause screen, kad neisjungtu pauzes esant in combat
	level_scene.get_node("PauseScreenView/PauseScreen").z_index = 10
	var combat_instance = COMBAT_SCENE.instantiate()
	var playerSprite = level_scene.get_node("Player/AnimatedSprite2D").duplicate()
	var combat_enemy = enemy.duplicate() # the whole enemy is taken instead of the sprite
	combat_instance.enemy = combat_enemy
	combat_instance.char_stats = level_scene.char_stats
	combat_instance.add_child(playerSprite) # add player character to combat
	combat_instance.add_child(combat_enemy) # add enemy instance to combat (using duplicated version)
	combat_instance.player = playerSprite
	#instance = combat_instance
	get_tree().paused = true
	current_view.call_deferred("add_child",combat_instance)
	#current_view.add_child(combat_instance)

func _on_game_in_combat_status_changed() -> void:
	Events.in_combat = !Events.in_combat
