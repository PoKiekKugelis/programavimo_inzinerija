extends Node

signal quit_while_in_combat
## Gets all UIs, during which game should not be able to be paused
@onready var UnpauseableUIs = get_tree().get_nodes_in_group("UnpausableUserInterfaces")
var in_combat = false
var can_unpause = true

func _pause():
	$VBoxContainer/Resume.grab_focus()
	get_tree().paused = true
	$".".visible = true

func _resume():
	$".".visible = false
	#esant kovoj, pauzes neisjungs
	if !in_combat:
		get_tree().paused = false
	
func _quit_to_menu():
	_resume()
	#problema ateiciai
	if in_combat:
		emit_signal("quit_while_in_combat")
	get_tree().change_scene_to_file("res://scenes/game scenes/main_menu.tscn")
	
func _input(event: InputEvent) -> void:
	if(Input.is_action_just_pressed("ui_pause") and (!get_tree().paused or (in_combat and !$".".visible) and !checkUI())):
		_pause()
	elif (Input.is_action_just_pressed("ui_pause") and get_tree().paused and !checkUI()):
		_resume()
		
	#Pauzes metu, kai fokusuojama ant Resume, dabar paspaudus "left" fokusavimas
	# bus perduodamas "Quit to Menu" mygtukui
	if $VBoxContainer/Resume.has_focus() == true and Input.is_action_just_pressed("ui_left"):
		$VBoxContainer/QuitContainer/QuitMenu.call_deferred("grab_focus")

#Checks if any node in group "UnpauseableUIs" is visible
func checkUI() -> bool:
	for i in range(len(UnpauseableUIs)):
		if UnpauseableUIs[i].visible == true:
			return true
	return false
	
#Button press event calls
func _on_resume_pressed() -> void:
	_resume()
	
func _on_quit_menu_pressed() -> void:
	_quit_to_menu()
	
func _on_quit_desktop_pressed() -> void:
	get_tree().quit()
func _on_game_in_combat_status_changed() -> void:
	in_combat = !in_combat
