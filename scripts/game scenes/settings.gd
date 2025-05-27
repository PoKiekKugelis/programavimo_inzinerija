extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# make sure UI connections are established
	_connect_signals()
	
	# configure volume slider
	$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Volume.min_value = 0
	$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Volume.max_value = 100
	
	# initialize UI elements with current settings
	_update_ui_from_settings()

# connect all UI signals manually to ensure they are working
func _connect_signals():
	# first disconnect any existing connections to avoid duplicates
	if $CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Volume.is_connected("value_changed", Callable(self, "_on_volume_value_changed")):
		$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Volume.value_changed.disconnect(_on_volume_value_changed)
	
	if $CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Mute.is_connected("toggled", Callable(self, "_on_mute_toggled")):
		$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Mute.toggled.disconnect(_on_mute_toggled)
	
	if $CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Resolution.is_connected("item_selected", Callable(self, "_on_resolutions_item_selected")):
		$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Resolution.item_selected.disconnect(_on_resolutions_item_selected)
	
	# now connect all signals
	$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Volume.value_changed.connect(_on_volume_value_changed)
	$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Mute.toggled.connect(_on_mute_toggled)
	$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Resolution.item_selected.connect(_on_resolutions_item_selected)
	
	# check if we have a fullscreen toggle checkbox and connect it
	if $CanvasModulate/PanelContainer/MarginContainer/VBoxContainer.has_node("Fullscreen"):
		if $CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Fullscreen.is_connected("toggled", Callable(self, "_on_fullscreen_toggled")):
			$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Fullscreen.toggled.disconnect(_on_fullscreen_toggled)
		$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Fullscreen.toggled.connect(_on_fullscreen_toggled)
	
	# connect navigation buttons
	var back_button = $CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/BackButton
	if back_button and !back_button.is_connected("pressed", Callable(self, "_on_back_pressed")):
		back_button.pressed.connect(_on_back_pressed)
	
	var input_button = $CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/InputButton
	if input_button and !input_button.is_connected("pressed", Callable(self, "_on_input_pressed")):
		input_button.pressed.connect(_on_input_pressed)

# update all UI elements from current settings
func _update_ui_from_settings():
	$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Volume.value = Settings.volume_percent
	$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Mute.button_pressed = Settings.is_muted
	$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Resolution.selected = Settings.resolution_index
	
	# set fullscreen checkbox if it exists
	if $CanvasModulate/PanelContainer/MarginContainer/VBoxContainer.has_node("Fullscreen"):
		$CanvasModulate/PanelContainer/MarginContainer/VBoxContainer/Fullscreen.button_pressed = Settings.fullscreen

func _on_volume_value_changed(value: float) -> void:
	Settings.set_volume_percent(value)
	Settings.save_settings()
	
func _on_mute_toggled(toggled_on: bool) -> void:
	Settings.is_muted = toggled_on
	AudioServer.set_bus_mute(0, toggled_on)
	Settings.save_settings()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	Settings.toggle_fullscreen(toggled_on)
	
func _on_resolutions_item_selected(index: int) -> void:
	Settings.resolution_index = index
	
	# apply the resolution change
	if !Settings.fullscreen:
		var resolution = Settings.resolution_presets[index]
		DisplayServer.window_set_size(resolution)
		
		# center the window
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - resolution) / 2
		DisplayServer.window_set_position(window_pos)
			
	# save both the resolution index and the current window size
	Settings.save_settings()
	
func _on_back_pressed() -> void:
	if get_parent().name == "MainMenu":
		$".".visible = false
		get_tree().paused = false
	else:
		$".".visible = false
		get_parent().get_node("PauseScreen").visible = true


func _on_input_pressed() -> void:
	if get_parent().name == "MainMenu":
		$"../InputSettingsScreen".visible = true
	else:
		$".".visible = false
		get_parent().get_node("InputSettingsScreen").visible = true
