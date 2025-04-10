extends CardState


func enter() -> void:
	card_ui.state.text = "CLICKED"
	card_ui.drop_point_detect.monitoring = true
	card_ui.original_index = card_ui.get_index()


func on_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		transition_requested.emit(self, CardState.State.DRAGGING)
