extends Control
class_name CardDeckView

const CARD_MENU_UI_SCENE := preload("res://cards/scenes/card_menu_ui.tscn")

@export var card_deck: CardDeck 
 
@onready var title: Label = %Title
@onready var cards: GridContainer = %Cards
@onready var back_button: Button = $BackButton
@onready var card_tooltip_popup: CardToolPopup = %CardTooltipPopup
@onready var card_deck_view: CardDeckView = $"."

func _ready() -> void:
	back_button.pressed.connect(
		func(): if (get_parent().get_parent().name == "CombatScreen"): 
			hide()
			else: get_tree().paused = !get_tree().paused; hide()
			)
	
	for card: Node in cards.get_children():
		card.queue_free()
	card_tooltip_popup.hide_tooltip()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_tooltip_popup.visible:
			card_tooltip_popup.hide_tooltip()
		elif card_deck_view.visible and get_parent().get_parent().name == "CombatScreen": 
			hide()
		elif card_deck_view.visible: 
			get_tree().paused = false
			hide()

func show_current_view(new_title: String, randomized: bool = false) -> void:
	for card: Node in cards.get_children():
		card.queue_free()
	card_tooltip_popup.hide_tooltip()
	title.text = new_title
	_update_view.call_deferred(randomized)
	
func _update_view(randomized: bool) -> void:
	if not card_deck:
		return
	var all_cards = card_deck.cards.duplicate()
	if randomized:
		all_cards.shuffle()
	
	for card: Card in all_cards:
		var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
		cards.add_child(new_card)
		new_card.card = card
		new_card.tooltip_requested.connect(card_tooltip_popup.show_tooltip)
	show()
	get_tree().paused = true
