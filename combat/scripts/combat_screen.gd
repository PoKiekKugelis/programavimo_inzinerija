extends Control
class_name CombatScreen
signal player_action_performed(message: String, color: Color)

# exported references for easy assignment in editor
@export var player: AnimatedSprite2D
@export var enemy: CharacterBody2D
@export var char_stats: CharStats

# element references
@onready var player_handler: PlayerHandler = $PlayerHandler as PlayerHandler
@onready var battle_ui: BattleUI = $BattleUI as BattleUI
@onready var player_health = GlobalHealth.get_health_instance()
@onready var enemy_handler: EnemyHandler = $EnemyHandler

func _ready() -> void:
	#Parent scene yra paused, bet šitos scenos physics (veikia signalai) yra active. Ez vienos eilutės fixas
	PhysicsServer2D.set_active(true)
	# initialize combat screen setup
	add_to_group("combat_screen")
	enemy_handler.add_child(enemy)
	enemy.reparent(enemy_handler)
	#connect signals
	Events.player_turn_ended.connect(player_handler.end_turn) # End turn function
	Events.player_hand_discarded.connect(player_handler.start_turn) # Start turn function
	Events.player_died.connect(_on_player_health_depleted) # Player death function
	#enemy_handler.child_order_changed.connect(_on_enemy_death) # enemy death function
	#add character stats such as energy, how many cards to draw and etc
	var new_stats: CharStats = char_stats.create_instance()
	battle_ui.char_stats = new_stats
	# Turn off physics (not falling) and process function
	enemy.set_physics_process(false)
	enemy.set_process(false)
	#timer for the transition
	await get_tree().create_timer(1.5).timeout
	#Change camera and prepare entities for combat
	$Camera2D.make_current()
	load_entities()
	#Timer for visible drawing cards
	await get_tree().create_timer(1.5).timeout
	player_handler.start_battle(new_stats)# Send the stats info everywhere and start drawing
	battle_ui.initialize_card_deck_ui()# Initialize the draw and discard piles
	# start with player's turn
	battle_ui.start_player_turn()

func _on_player_health_depleted() -> void:
	$BattleUI.visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game scenes/death_screen.tscn")
	queue_free()

func _on_enemy_death() -> void: # Added those two lines. Crashes if you close the game and go to main menu but works otherwise
	if enemy_handler.get_child_count() == 0: # Added enemy_handler logic to check if any enmies are still alive
		battle_ui.show_action_text("Enemy defeated!", Color.GREEN)
		await get_tree().create_timer(1.5).timeout
		var victory_screen = preload("res://combat/scenes/victory_screen.tscn").instantiate()
		get_node("GameOverScreen").add_child(victory_screen) # Added the victory screen to a CanvasLayer
		if victory_screen.has_signal("continue_game"):
			victory_screen.connect("continue_game", Callable(self, "_on_continue_after_victory"))

func _on_continue_after_victory() -> void:
	# clean up combat scene
	$BattleUI.visible = false
	get_tree().paused = false
	queue_free()

# loads and positions combat entities
func load_entities():
	player.visible = true
	enemy.visible = true
	$BattleUI.visible = true
	set_transformations()

# positions and scales combat sprites
func set_transformations():
	player.position = Vector2(300, 450)
	enemy.position = Vector2(900, 500)
	player.scale = Vector2(3,3)
	enemy.scale = Vector2(6, 6)
	# make enemy face left
	var anim_sprite = enemy.get_node("AnimatedSprite2D")
	anim_sprite.flip_h = true
	# setup enemy animation
	anim_sprite.play("idle")
