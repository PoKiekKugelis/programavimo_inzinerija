extends Control
class_name CardUI

signal reparent_requested(which_card_ui: CardUI)

@export var card: Card : set = set_card
@export var char_stats: CharStats : set = set_char_stats

@onready var texture_rect: TextureRect = $TextureRect
@onready var cost: Label = $TextureRect/Cost
@onready var state: Label = $State
@onready var drop_point_detect: Area2D = $DropPointDetect
@onready var card_state_machine: CardStateMachine = $CardStateMachine as CardStateMachine
@onready var targets: Array[Node] = []

var original_index := 0
var playable := true : set = set_playable
var disabled := false
var parent: Control

func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	card = value
	cost.text = str(card.cost)
	texture_rect.texture = card.icon

func set_char_stats(value: CharStats) -> void:
	char_stats = value
	char_stats.stats_changed.connect(on_char_stats_changed)

func on_char_stats_changed() -> void:
	self.playable = char_stats.can_play_card(card)

func _ready() -> void:
	card_state_machine.init(self)

func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()

func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()

func _on_drop_point_detect_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)

func _on_drop_point_detect_area_exited(area: Area2D) -> void:
	targets.erase(area)

func play() -> void:
	if not card:
		return
	
	card.play(targets, char_stats)
	queue_free()

func set_playable(value: bool) -> void:
	playable = value
	if not playable:
		cost.add_theme_color_override("font_color", Color.RED)
		cost.modulate = Color(1, 1, 1, 0.5)
	else:
		cost.remove_theme_color_override("font_color")
		cost.modulate = Color(1, 1, 1, 1)
