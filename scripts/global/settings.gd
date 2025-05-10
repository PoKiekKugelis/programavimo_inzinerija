extends Node

# default settings
var volume: float = 0.0  
var volume_percent: float = 50.0  
var is_muted: bool = false
var resolution_index: int = 5
var fullscreen: bool = false  

# resolution presets (width, height)
var resolution_presets = [
	Vector2i(2560, 1440),  
	Vector2i(1920, 1080),  
	Vector2i(1600, 900),   
	Vector2i(1440, 900),   
	Vector2i(1280, 720),   
	Vector2i(1152, 648)   
]

# config file path
var config_path = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	# this needs to be called before load_settings to ensure proper initialization
	load_settings()
	
# convert percentage (0-100) to decibels (-80 to 0)
func percent_to_db(percent: float) -> float:
	if percent <= 0:
		return -80.0  # effectively muted
	return linear_to_db(percent / 100.0)
	
# save all settings to config file
func save_settings():
	config.set_value("audio", "volume_percent", volume_percent)
	config.set_value("audio", "muted", is_muted)
	config.set_value("video", "resolution_index", resolution_index)
	config.set_value("video", "fullscreen", fullscreen)
	
	# save current window size only if not in fullscreen
	if not fullscreen:
		var current_size = DisplayServer.window_get_size()
		config.set_value("video", "window_width", current_size.x)
		config.set_value("video", "window_height", current_size.y)

	
	# save input mappings
	var actions = InputMap.get_actions()
	for action in actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event_data = _serialize_input_event(events[0])
			config.set_value("input", action, event_data)
	
	# save to disk
	var error = config.save(config_path)


# load settings from config file
func load_settings():
	# check if config file exists
	var error = config.load(config_path)
	
	# if file exists, load values
	if error == OK:
		volume_percent = config.get_value("audio", "volume_percent", 50.0)
		is_muted = config.get_value("audio", "muted", false)
		resolution_index = config.get_value("video", "resolution_index", resolution_index)
		fullscreen = config.get_value("video", "fullscreen", false)
		
		# load window size if available
		var window_width = config.get_value("video", "window_width", resolution_presets[resolution_index].x)
		var window_height = config.get_value("video", "window_height", resolution_presets[resolution_index].y)
		
		# load input mappings
		var actions = InputMap.get_actions()
		for action in actions:
			if config.has_section_key("input", action):
				var event_data = config.get_value("input", action, {})
				var event = _deserialize_input_event(event_data)
				
				if event:
					InputMap.action_erase_events(action)
					InputMap.action_add_event(action, event)
		
		# apply loaded settings with a slight delay to ensure proper window setup
		apply_settings(window_width, window_height)
	else:
		# if file doesn't exist, save default values
		apply_settings()
		save_settings()

# apply current settings to the game
func apply_settings(custom_width = null, custom_height = null):
	# apply audio settings
	volume = percent_to_db(volume_percent)
	AudioServer.set_bus_volume_db(0, volume)
	AudioServer.set_bus_mute(0, is_muted)
	
	# apply window mode first (fullscreen vs windowed)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	
	# apply resolution settings if in windowed mode
	if not fullscreen:
		var target_size = Vector2i()
		
		if custom_width != null and custom_height != null:
			# use custom dimensions if provided
			target_size = Vector2i(custom_width, custom_height)
		else:
			# otherwise use the resolution based on index
			target_size = resolution_presets[resolution_index]
		
		DisplayServer.window_set_size(target_size)
		
		# center the window
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - target_size) / 2
		DisplayServer.window_set_position(window_pos)
	
			
# set volume from percentage (0-100)
func set_volume_percent(percent: float):
	volume_percent = percent
	volume = percent_to_db(percent)
	AudioServer.set_bus_volume_db(0, volume)

# toggle fullscreen mode
func toggle_fullscreen(enable: bool):
	fullscreen = enable
	
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# Restore windowed resolution
		DisplayServer.window_set_size(resolution_presets[resolution_index])
	
	save_settings()

# helper functions to serialize and deserialize input events
func _serialize_input_event(event):
	var data = {}
	
	# common properties
	data["type"] = event.get_class()
	
	# handle keyboard events
	if event is InputEventKey:
		data["keycode"] = event.keycode
		data["physical_keycode"] = event.physical_keycode
		data["unicode"] = event.unicode
		data["pressed"] = event.pressed
		data["alt_pressed"] = event.alt_pressed
		data["shift_pressed"] = event.shift_pressed
		data["ctrl_pressed"] = event.ctrl_pressed
		data["meta_pressed"] = event.meta_pressed
	
	# handle mouse button events
	elif event is InputEventMouseButton:
		data["button_index"] = event.button_index
		data["pressed"] = event.pressed
		data["double_click"] = event.double_click
		data["factor"] = event.factor
		
	
	
	return data

func _deserialize_input_event(data):
	if not data or not data.has("type"):
		return null
		
	var event = null
	
	# create the appropriate event type
	match data["type"]:
		"InputEventKey":
			event = InputEventKey.new()
			if data.has("keycode"): event.keycode = data["keycode"]
			if data.has("physical_keycode"): event.physical_keycode = data["physical_keycode"]
			if data.has("unicode"): event.unicode = data["unicode"] 
			if data.has("echo"): event.echo = data["echo"]
			if data.has("pressed"): event.pressed = data["pressed"]
			if data.has("alt_pressed"): event.alt_pressed = data["alt_pressed"]
			if data.has("shift_pressed"): event.shift_pressed = data["shift_pressed"]
			if data.has("ctrl_pressed"): event.ctrl_pressed = data["ctrl_pressed"]
			if data.has("meta_pressed"): event.meta_pressed = data["meta_pressed"]
			
		"InputEventMouseButton":
			event = InputEventMouseButton.new()
			if data.has("button_index"): event.button_index = data["button_index"]
			if data.has("pressed"): event.pressed = data["pressed"]
			if data.has("double_click"): event.double_click = data["double_click"]
			if data.has("factor"): event.factor = data["factor"]
			
	
	
	return event
