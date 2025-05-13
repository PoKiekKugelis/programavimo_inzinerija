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

@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var victory_sound: AudioStreamPlayer2D = $VictorySound

@onready var turn_counter: int = 1

func _ready() -> void:
	enemy.setup_ai()
	# Tree is still paused but the area_entered signal needs to stay active, therefore PhysicsServer2D is set to active
	PhysicsServer2D.call_deferred("set_active", true)
	add_to_group("combat_screen") # So far unnecessary
	enemy.call_deferred("reparent", enemy_handler) # Enemy is under the enemy_handler so it's easier if there are multiple enemies
	setup_event_connections() # Connect signals
	battle_ui.char_stats = char_stats # Provide BattleUI the character stats
	# Turn off physics (not falling) and process function
	enemy.set_physics_process(false)
	enemy.set_process(false)
	battle_ui.add_card_sprites()
	await get_tree().create_timer(1.5).timeout# Timer for the transition
	$Camera2D.make_current()# Change camera and prepare entities for combat
	load_entities() # Setup enemies and player to look proper
	start_battle() # Start the battle

func setup_event_connections() -> void:
	Events.player_turn_ended.connect(player_handler.end_turn) # End turn function
	Events.player_hand_discarded.connect(enemy_handler.start_turn) # Start turn function
	Events.player_died_in_combat.connect(_on_player_death) # Player death function
	enemy_handler.child_order_changed.connect(_on_enemy_death) # enemy death function
	Events.enemy_turn_ended.connect(on_enemy_turn_ended)

func start_battle() -> void:# Starts the battle, for continued turn logic see on_enemy_turn_ended
	await get_tree().create_timer(1.5).timeout# Initial timer for visible drawing cards
	enemy_handler.reset_enemy_actions()# This assigns the enemy an action
	player_handler.start_battle(char_stats)# Send the stats info everywhere and start drawing
	battle_ui.initialize_card_deck_ui()# Initialize the draw and discard piles
	battle_ui.start_player_turn()# Start alternating between turns for display
	battle_ui.display_action()# Display enemy intended action
	$BattleUI/Turn/TurnCounter.text=str(turn_counter)

func _on_player_death() -> void:
	get_tree().paused = false
	Events.player_died.emit()
	queue_free()

func _on_enemy_death() -> void: # Added those two lines
	if enemy_handler.get_child_count() == 0 and is_inside_tree(): # Added enemy_handler logic to check if any enemies are still alive
		death_sound.play()
		battle_ui.show_action_text("Enemy defeated!", Color.GREEN)
		await get_tree().create_timer(1.5).timeout
		var victory_screen = preload("res://combat/scenes/victory_screen.tscn").instantiate()
		if !victory_sound.playing:
			victory_sound.play()
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
	player.position = Vector2(300, 400)
	enemy.position = Vector2(900, 400)
	player.scale = Vector2(5,5)
	enemy.scale = Vector2(5,5)
	# make player face right and enemy face left
	var anim_sprite = enemy.get_node("AnimatedSprite2D")
	anim_sprite.flip_h = false
	player.flip_h = false
	# setup player and enemy animations
	anim_sprite.play("idle")
	player.play("idle")
	show_enemy_health()# Make enemy health bars visible

func show_enemy_health():
	for enemy in $EnemyHandler.get_children():
		var health_bar = enemy.get_node("HealthBar")
		health_bar.visible = true

func on_enemy_turn_ended() -> void:
	battle_ui.show_action_text(enemy.current_action.message)# Display what the enemy did (prob wont need it later) cluster
	battle_ui.start_player_turn()# return to player's turn
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()
	battle_ui.display_action()#Display the intent
	turn_counter+=1
	$BattleUI/Turn/TurnCounter.text=str(turn_counter)
