extends Node
class_name Run

#apsirašyti  visas scenas, kurias inicializuos run mazgas
const COMBAT_SCENE:= preload("res://combat/scenes/combat_screen.tscn")
const RUN_COMPLETE:= preload("res://scenes/game scenes/level_complete.tscn")
const PLAYER_DEATH:= preload("res://scenes/game scenes/death_screen.tscn")#numirus nebe change current scene, o per signals atsiųsti čia, kad pakeistų sceną

# Pakeičiau į masyvą
const LEVEL_SCENES:= [preload("res://scenes/game scenes/game.tscn"),
					 preload("res://scenes/game scenes/level1.tscn")]
# Stations sudejau i masyva kad galeciau random 1 paimt
const STATIONS:= [preload("res://scenes/game scenes/stations/mine_station.tscn"),
				preload("res://scenes/game scenes/stations/scrapyard_station.tscn"),
				preload("res://scenes/game scenes/stations/tree_station.tscn")]

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
var level_index: int = 0# levels masyvui

var visited_station: bool = false
# kolkas, kol su pinigais gali patekt i station,
# naudojamas bool, kad nesoftlockint saves station

func _ready() -> void:
	add_node_resources()

func start_run() -> void:
	on_level_entered()
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
	Events.changing_level.connect(func(): update_run(level_scene))
	# Turint daugiau nei viena lygi, bind neveikia, "free'inus" level_scene, argumentas vistiek
	# islieka kaip "previously freed", todel pakeiciau i func(): -Velyvis
	Events.run_continues.connect(on_level_entered)
	Events.enter_combat.connect(_on_player_enter_combat)
	Events.in_combat_status_changed.connect(_in_combat_status_changed)# combat ended signal

func on_level_entered() -> void:# Sujungiau abu level_entered į vieną metodą
	# Kol turim 2 lygius, tai tik vienoj vietoj gali but station, tai jokio previous level
	# kintamojo nereikia
	var roll = randi() % 10 # 1/10 sansas gauti station
	# Jeigu isridena 0, tai keicia lygi, i random station
	# Testavimui: kai pinigai 37, irgi pakeis scena
	# Papildomas bool, kol su pinigais galima patekt i station (softlock prevention) 
	# Taigi turint 37 pinigus, visada bus bent viena karta
	if (roll == 0 or (Money.get_money() == 37 and !visited_station)):
		visited_station = true
		level_scene = change_view(STATIONS[randi() % 3])
	else:
		level_scene = change_view(LEVEL_SCENES[level_index])
		level_index += 1
	update_player(level_scene)

# synchronizes player's health and stamina with the ui elements in the scene
func update_player(scene) -> void:
	# updates the character stats
	if character:
		scene.player.char_stats = character
		scene.player.connect_deck()
	# updates health values and links healthbar UI if available
	if scene.player and scene.player.health and health:
		scene.player.health.set_max_health(health.max_health)
		scene.player.health.set_health(health.health)
		if scene.has_node("Player/PlayerUI/HealthBar"):
			scene.get_node("Player/PlayerUI/HealthBar").setup_health_bar(scene.player.health)
	# updates stamina values and links staminabar UI if available
	if scene.player and scene.player.stamina and stamina:
		scene.player.stamina.max_stamina = stamina.max_stamina
		scene.player.stamina.stamina = stamina.stamina
		if scene.has_node("Player/PlayerUI/StaminaBar"):
			scene.get_node("Player/PlayerUI/StaminaBar").setup_stamina_bar()

func update_run(scene) -> void:# Ιš scenos player priskiria duomenis į run'ą 
	character = scene.player.char_stats
	health.set_max_health(scene.player.health.max_health)
	health.set_health(scene.player.health.health)
	stamina.max_stamina = scene.player.stamina.max_stamina
	stamina.stamina = scene.player.stamina.stamina

func _on_player_enter_combat(enemy: CharacterBody2D) -> void:
	Events.in_combat_status_changed.emit()#naudojamas pause screen, kad neisjungtu pauzes esant in combat
	level_scene.get_node("PauseScreenView/PauseScreen").z_index = 10
	var combat_instance = COMBAT_SCENE.instantiate()
	var playerSprite = level_scene.get_node("Player/AnimatedSprite2D").duplicate()
	var combat_enemy = enemy.duplicate() # the whole enemy is taken instead of the sprite
	combat_instance.enemy = combat_enemy
	combat_instance.char_stats = level_scene.get_node("Player").char_stats
	combat_instance.add_child(playerSprite) # add player character to combat
	combat_instance.add_child(combat_enemy) # add enemy instance to combat (using duplicated version)
	combat_instance.player = playerSprite
	get_tree().paused = true
	current_view.call_deferred("add_child",combat_instance)

func _in_combat_status_changed() -> void:
	Events.in_combat = !Events.in_combat
	hide_player_ui()

func hide_player_ui() -> void:
	if level_scene:
		var player_ui = level_scene.get_node("Player/PlayerUI")
		if player_ui:
			player_ui.visible = !Events.in_combat
