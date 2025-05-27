extends Node

# Base reward configuration
@export var base_reward: int = 50
@export var reward_variance_percent: float = 10.0

@onready var button: Button = $Button
@onready var reward_label: Label = $RewardLabel 
@onready var coin: Sprite2D = $Coin

func _ready() -> void:
	# Connect button signal
	button.pressed.connect(_on_button_pressed)
	
	# calculate and award reward when victory screen appears
	award_victory_reward()

func _on_button_pressed() -> void:
	# Return to the main game
	get_tree().paused = false
	Events.in_combat_status_changed.emit()
	get_parent().get_parent().queue_free()
	
	# Emit a signal that the parent can connect to
	# You'll need to define this signal at the top of the script
	emit_signal("continue_game")

func award_victory_reward():
	# calculate random reward with +10% or -10% variance
	var variance_amount = base_reward * (reward_variance_percent / 100.0)
	var min_reward = base_reward - variance_amount
	var max_reward = base_reward + variance_amount
	
	# generate random reward within range
	var coins_earned = randi_range(int(min_reward), int(max_reward))
	
	# award the money to the player
	Money.add_money(coins_earned)
	
	# display the reward on screen
	reward_label.text = "You earned " + str(coins_earned) + " coins!"
	coin.visible = true;
	
