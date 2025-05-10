extends Control

# preloaded scene for input button instances
@onready var input_button_scene = preload("res://scenes/signs and menus/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

# variables to track remapping state
var is_remapping = false
var action_to_remap = null
var remapping_button = null

# dictionary mapping action names to their display names
var input_actions = {
	"left": "Move left",
	"right": "Move right",
	"ui_jump": "Jump",
	"ui_inventory": "Open inventory",
	"pick_up": "Pick up",
	"ui_sprint": "Sprint",
	"ui_pause": "Pause",
}

func _ready():
	create_action_list()
	# ensures this node processes even when the game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func create_action_list():
	 
	# clear existing buttons
	for item in action_list.get_children():
		item.queue_free()
	 
	# create a button for each input action
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		# set the action's display name
		action_label.text = input_actions[action]
		
		# get and display the current key binding
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		# add the button and connect its signal
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
		
func _on_input_button_pressed(button, action):
	# start the remapping process when a button is pressed
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."
		
func _input(event):
	# handle input events during remapping
	if is_remapping:
		if event is InputEventKey || event is InputEventMouseButton && event.pressed:
			# replace the existing mapping with the new input
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			update_action_list(remapping_button, event)
			
			# save the updated keybindings
			Settings.save_settings()
			
			# reset remapping state
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			# prevent the event from propagating further
			accept_event()

func update_action_list(button, event):
	# update the button display with the new key binding
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")

func _on_reset_button_pressed() -> void:
	# reset all keybindings to default
	InputMap.load_from_project_settings()
	create_action_list()
	Settings.save_settings()

func _on_back_button_pressed() -> void:
	# hide this screen and show the settings screen
	$".".visible = false
	get_parent().get_node("SettingsScreen").visible = true
