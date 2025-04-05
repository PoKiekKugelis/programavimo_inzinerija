extends CanvasLayer
class_name BattleUI

@export var char_stats: CharStats : set = set_char_stats

@onready var hand: Hand = $Hand as Hand
@onready var energy_ui: EnergyUI = $EnergyUI as EnergyUI
@onready var end_turn_button: Button = %EndTurnButton
@onready var draw_button: CardDeckOpen = %DrawButton
@onready var discard_button: CardDeckOpen = %DiscardButton
@onready var draw_deck_view: CardDeckView = %DrawDeckView
@onready var discard_deck_view: CardDeckView = %DiscardDeckView

func _ready() -> void:
	Events.player_hand_drawn.connect(on_player_hand_drawn)
	end_turn_button.pressed.connect(on_end_turn_button_pressed)
	draw_button.pressed.connect(draw_deck_view.show_current_view.bind("Draw Pile", true))
	discard_button.pressed.connect(discard_deck_view.show_current_view.bind("Discard Pile"))

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
	Events.player_turn_ended.emit()
