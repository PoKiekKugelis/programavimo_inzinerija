extends CanvasLayer
class_name BattleUI

# turn states for tracking whose turn it is
enum TurnState { PLAYER_TURN, ENEMY_TURN }

@export var char_stats: CharStats : set = set_char_stats
@export var enemy: CharacterBody2D

@onready var turn_indicator = $TurnIndicator
@onready var hand: Hand = $Hand as Hand
@onready var energy_ui: EnergyUI = $EnergyUI as EnergyUI
@onready var end_turn_button: Button = %EndTurnButton
@onready var draw_button: CardDeckOpen = %DrawButton
@onready var discard_button: CardDeckOpen = %DiscardButton
@onready var draw_deck_view: CardDeckView = %DrawDeckView
@onready var discard_deck_view: CardDeckView = %DiscardDeckView
@onready var choice: int
@onready var action_text = $ActionText
@onready var combat_screen: CombatScreen = $".."
# animation helpers
@onready var text_tween = create_tween()
@onready var tooltip_tween = create_tween().set_parallel(true)

# current turn state
var current_turn: TurnState = TurnState.PLAYER_TURN

func _ready() -> void:
	#disable button so first turn you don't draw more than once
	end_turn_button.disabled = true
	Events.player_hand_drawn.connect(on_player_hand_drawn)# connect the signal to the function
	# connect the buttons to the functions
	end_turn_button.pressed.connect(on_end_turn_button_pressed)
	draw_button.pressed.connect(draw_deck_view.show_current_view.bind("Draw Pile", true))
	discard_button.pressed.connect(discard_deck_view.show_current_view.bind("Discard Pile"))
	
	# style turn indicator text
	turn_indicator.add_theme_color_override("font_outline_color", Color.BLACK)
	turn_indicator.add_theme_constant_override("outline_size", 4)
	
	# connect the enemy from combat screen to battleUI for enemy combat AI logic
	enemy = combat_screen.enemy

func initialize_card_deck_ui() -> void:
	draw_button.card_deck = char_stats.draw_deck
	draw_deck_view.card_deck = char_stats.draw_deck
	discard_button.card_deck = char_stats.discard
	discard_deck_view.card_deck = char_stats.discard

func set_char_stats(value: CharStats) -> void:
	char_stats = value
	energy_ui.char_stats = char_stats
	hand.char_stats = char_stats

func on_player_hand_drawn() -> void:
	end_turn_button.disabled = false

func on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	if current_turn == TurnState.PLAYER_TURN:
		start_enemy_turn()
	Events.player_turn_ended.emit()

# starts player's turn
func start_player_turn():
	display_action() #displays enemy's action
	current_turn = TurnState.PLAYER_TURN
	turn_indicator.text = "PLAYER'S TURN"
	turn_indicator.modulate = Color.GREEN

# handles enemy's turn with actions
func start_enemy_turn():
	current_turn = TurnState.ENEMY_TURN
	turn_indicator.text = "ENEMY'S TURN"
	turn_indicator.modulate = Color.RED
	await get_tree().create_timer(1.0).timeout
	play_enemy_turn()# enemy performs 2 random actions
	
	# after enemy finishes their actions, clear the shield
	var player_health = GlobalHealth.get_health_instance()
	player_health.clear_shield()
	
	start_player_turn()# return to player's turn

func play_enemy_turn():
	if choice == 0:
		# deal damage
		var player_health = GlobalHealth.get_health_instance()
		#player_health.set_health(player_health.health - 2)
		player_health.receive_damage(2)
		show_action_text("Enemy dealt 2 damage!", Color.RED)
	elif choice == 1:
		# heal self
		var enemy_health = enemy.get_node("Health")
		enemy_health.set_health(enemy_health.health + 2)
		show_action_text("Enemy healed 2 HP!", Color.GREEN)
		
		await get_tree().create_timer(0.5).timeout

func display_action():
	choice = randi() % 2
	$Choice.visible = true
	if choice == 0:
		# deal damage
		$Choice.text = "Attack: 2 HP"
		$Choice.add_theme_color_override("font_color", Color(1,0,0,1))
	elif choice == 1:
		# heal self
		$Choice.text = "Heal: 2 HP"
		$Choice.add_theme_color_override("font_color", Color(0,1,0,1))

# displays combat action text with fade effect
func show_action_text(message: String, color: Color = Color.WHITE):
	action_text.text = message
	action_text.modulate = color
	text_tween.kill()
	text_tween = create_tween()
	text_tween.tween_property(action_text, "modulate:a", 0.0, 1.0).set_delay(0.5)
	text_tween.tween_callback(func(): action_text.text = "")
