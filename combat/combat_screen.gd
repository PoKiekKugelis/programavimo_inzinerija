extends Control

# turn states for tracking whose turn it is
enum TurnState { PLAYER_TURN, ENEMY_TURN }

# exported references for easy assignment in editor
@export var player: Sprite2D
@export var enemy: CharacterBody2D

# ui element references
@onready var end_turn_button = $BattleUI/EndTurnButton
@onready var action_text = $BattleUI/ActionText
@onready var turn_indicator = $BattleUI/TurnIndicator

# animation helpers
@onready var text_tween = create_tween()
@onready var tooltip_tween = create_tween().set_parallel(true)

# current turn state
var current_turn: TurnState = TurnState.PLAYER_TURN

signal player_action_performed(message: String, color: Color)

func _ready() -> void:
	# initialize combat screen setup
	add_to_group("combat_screen")
	
	# connect button actions to text display
	$BattleUI/DamageButton1.pressed.connect(
		func(): show_action_text("Player dealt 1 damage!", Color.RED)
	)
	$BattleUI/DamageButton2.pressed.connect(
		func(): show_action_text("Player dealt 2 damage!", Color.RED)
	)
	$BattleUI/HealButton.pressed.connect(
		func(): show_action_text("Player healed 1 HP!", Color.GREEN)
	)
	
	# setup enemy health bar
	var enemy_health = enemy.get_node("Health")
	$BattleUI/EnemyHealth.setup_health_bar(enemy_health)
	
	# initial delay for combat start
	await get_tree().create_timer(1).timeout
	$Camera2D.make_current()
	
	# prepare entities for combat
	load_entities()
	
	# configure enemy for combat
	enemy.visible = true
	enemy.set_physics_process(false)
	enemy.set_process(false)
	enemy.velocity = Vector2.ZERO
	enemy.is_roaming = false
	enemy.is_enemy_chase = false
	
	# setup enemy animation
	var anim_sprite = enemy.get_node("AnimatedSprite2D")
	anim_sprite.stop()
	anim_sprite.play("idle")
	
	# connect ui signals
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
	# make action buttons invisible
	$BattleUI/DamageButton1.modulate.a = 0
	$BattleUI/DamageButton2.modulate.a = 0
	$BattleUI/HealButton.modulate.a = 0
	
	# setup tooltips
	$BattleUI/ActionTooltip.visible = false
	$BattleUI/DamageButton1.mouse_entered.connect(
		func(): _show_tooltip("Deal 1 damage", $BattleUI/DamageButton1)
	)
	$BattleUI/DamageButton2.mouse_entered.connect(
		func(): _show_tooltip("Deal 2 damage", $BattleUI/DamageButton2)
	)
	$BattleUI/HealButton.mouse_entered.connect(
		func(): _show_tooltip("Heal 1 HP", $BattleUI/HealButton)
	)
	
	# connect mouse exit signals
	$BattleUI/DamageButton1.mouse_exited.connect(_hide_tooltip)
	$BattleUI/DamageButton2.mouse_exited.connect(_hide_tooltip)
	$BattleUI/HealButton.mouse_exited.connect(_hide_tooltip)
	
	# style turn indicator text
	turn_indicator.add_theme_color_override("font_outline_color", Color.BLACK)
	turn_indicator.add_theme_constant_override("outline_size", 4)
	
	# start with player's turn
	start_player_turn()

# shows tooltip text above button
func _show_tooltip(text: String, button: Button):
	$BattleUI/ActionTooltip.text = text
	$BattleUI/ActionTooltip.visible = true
	$BattleUI/ActionTooltip.position = button.position + Vector2(0, -40)
	
# hides tooltip
func _hide_tooltip():
	$BattleUI/ActionTooltip.visible = false

# TODO: implement a working death screen when players dies
func _on_player_death():
	await get_tree().create_timer(2.0).timeout 
	get_tree().paused = true
	var death_screen = preload("res://scenes/death_screen.tscn").instantiate()
	get_tree().root.add_child(death_screen)
	$BattleUI.visible = false
	
# TODO: needs to show a victory screen or something when the enemy is dead
func _on_enemy_death():
	pass

# displays combat action text with fade effect
func show_action_text(message: String, color: Color = Color.WHITE):
	action_text.text = message
	action_text.modulate = color
	text_tween.kill()
	text_tween = create_tween()
	text_tween.tween_property(action_text, "modulate:a", 0.0, 1.0).set_delay(0.5)
	text_tween.tween_callback(func(): action_text.text = "")

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
	player.scale = Vector2(1.5,1.5)
	enemy.scale = Vector2(6, 6)
	
	# make enemy face left
	var anim_sprite = enemy.get_node("AnimatedSprite2D")
	anim_sprite.flip_h = true

# starts player's turn
func start_player_turn():
	current_turn = TurnState.PLAYER_TURN
	end_turn_button.disabled = false
	turn_indicator.text = "PLAYER'S TURN"
	turn_indicator.modulate = Color.GREEN

# handles enemy's turn with actions
func start_enemy_turn():
	current_turn = TurnState.ENEMY_TURN
	end_turn_button.disabled = true
	turn_indicator.text = "ENEMY'S TURN"
	turn_indicator.modulate = Color.RED
	await get_tree().create_timer(3.0).timeout
	
	# enemy performs 2 random actions
	for i in range(2):
		var choice = randi() % 2
		
		if choice == 0:
			# deal damage
			var player_health = GlobalHealth.get_health_instance()
			player_health.set_health(player_health.health - 1)
			show_action_text("Enemy dealt 1 damage!", Color.RED)
		elif choice == 1:
			# heal self
			var enemy_health = enemy.get_node("Health")
			enemy_health.set_health(min(enemy_health.health + 1, enemy_health.max_health))
			show_action_text("Enemy healed 1 HP!", Color.GREEN)
		
		await get_tree().create_timer(2.0).timeout
	
	# return to player's turn
	start_player_turn()

# end turn button handler
func _on_end_turn_button_pressed() -> void:
	if current_turn == TurnState.PLAYER_TURN:
		start_enemy_turn()
