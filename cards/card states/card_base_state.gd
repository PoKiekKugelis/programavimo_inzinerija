extends CardState

@onready var tween = create_tween()
var hover_offset := -50

func enter() -> void:
	if not card_ui.is_node_ready():
		await card_ui.ready
	
	card_ui.reparent_requested.emit(card_ui)
	card_ui.pivot_offset = Vector2.ZERO
	if card_ui.parent and card_ui.parent is Hand:
		card_ui.parent.update_cards()
		card_ui.texture_rect.position = card_ui.drop_point_detect.position

func on_gui_input(event: InputEvent) -> void:
	if not card_ui.playable or card_ui.disabled:
		return
	if event.is_action_pressed("left_mouse") and !is_tweening:
		# is_tweening pridėjau, kad on_gui_input patikrintų click'inant. Kitu atveju įmanoma paspausti tween'inant.
		# Hand yra konteineris ir jis savo x, y koordinates savo vaikams turi, o Paclick'inus tampa nebecontainer
		# vaiku ir jo koordinatės tampa combat scenos. Per tą 0.05 sec left click'inus
		# korta nuskrenda į aukštesnę koordinatę - atrodo funky ir netyčia gali panaudoti nenorimą kortą.
		card_ui.pivot_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self, CardState.State.CLICKED)

func on_mouse_entered() -> void:
	tween.kill()
	tween = create_tween()
	is_tweening = true
	await tween.tween_property(card_ui, "position:y",card_ui.original_position.y + hover_offset, 0.03).finished
	is_tweening = false

func on_mouse_exited() -> void:
	tween.kill()
	tween = create_tween()
	is_tweening = true
	await tween.tween_property(card_ui, "position:y",card_ui.original_position.y, 0.03).finished
	is_tweening = false
