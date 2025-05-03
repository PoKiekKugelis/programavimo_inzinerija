extends CardState

func enter() -> void:
	var ui_layer = get_tree().get_first_node_in_group("ui_layer")
	card_ui.rotation_degrees = 0
	if ui_layer:
		card_ui.reparent(ui_layer)
		card_ui.texture_rect.position = card_ui.drop_point_detect.position

func on_input(event: InputEvent) -> void:
	var mouse_motion := event is InputEventMouseMotion
	var cancel = event.is_action_pressed("right_mouse")
	var confirm = event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")
	
	if mouse_motion:
		card_ui.global_position = card_ui.get_global_mouse_position() - card_ui.pivot_offset
	if cancel:
		transition_requested.emit(self, CardState.State.BASE)
	elif confirm:
		get_viewport().set_input_as_handled()
		transition_requested.emit(self, CardState.State.RELEASED)
