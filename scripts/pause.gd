extends Node

## Gets all UIs, during which game should not be able to be paused
@onready var UnpauseableUIs = get_tree().get_nodes_in_group("UnpausableUserInterfaces")

func _pause():
	$VBoxContainer/Resume.grab_focus()
	get_tree().paused = true
	$".".visible = true

func _resume():
	get_tree().paused = false
	$".".visible = false
	
func _quit_to_menu():
	_resume()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	#Checks if any node in group "UnpauseableUIs" is visible
	for i in range(len(UnpauseableUIs)):
		if UnpauseableUIs[i].visible == true: 	#if atleast one is visible it _process returns
			return 								#without other chekcs
		else:									#if no node is visible, it continues as before
			if(Input.is_action_just_pressed("ui_pause", true) and !get_tree().paused ):
				_pause()
			elif (Input.is_action_just_pressed("ui_unpause", true) and get_tree().paused):
				_resume()
		
	#Pauzes metu, kai fokusuojama ant Resume, dabar paspaudus "left" fokusavimas
	# bus perduodamas "Quit to Menu" mygtukui
	if $VBoxContainer/Resume.has_focus() == true and Input.is_action_just_pressed("ui_left"):
		$VBoxContainer/QuitContainer/QuitMenu.call_deferred("grab_focus")
		
#Button press event calls
func _on_resume_pressed() -> void:
	_resume()
	
func _on_quit_menu_pressed() -> void:
	_quit_to_menu()
	
func _on_quit_desktop_pressed() -> void:
	get_tree().quit()
	
