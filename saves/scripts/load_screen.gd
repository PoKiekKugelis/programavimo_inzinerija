extends Control

var save_file_1 = "res://saves/userData1.save"
var save_file_2 = "res://saves/userData2.save"
var save_file_3 = "res://saves/userData3.save"
var using_controller := false

@export var current_scene: String

signal button_pressed

##Save file Selection

func _on_file_1_pressed() -> void:
	SaveFiles.path = save_file_1
	emit_signal("button_pressed")
	await get_tree().create_timer(2).timeout
	# Uzkomentuota kol neturim mid run saves
	#var target_scene = SaveSystem.load_game().get("Location", "res://scene managers/scenes/game_save.tscn")
	var target_scene = "res://scene managers/scenes/game_save.tscn"
	get_tree().change_scene_to_file(target_scene)

func _on_file_2_pressed() -> void:
	SaveFiles.path = save_file_2
	emit_signal("button_pressed")
	await get_tree().create_timer(2).timeout
	# Uzkomentuota kol neturim mid run saves
	#var target_scene = SaveSystem.load_game().get("Location", "res://scene managers/scenes/game_save.tscn")
	var target_scene = "res://scene managers/scenes/game_save.tscn"
	
func _on_file_3_pressed() -> void:
	SaveFiles.path = save_file_3
	emit_signal("button_pressed")
	await get_tree().create_timer(2).timeout
	# Uzkomentuota kol neturim mid run saves
	#var target_scene = SaveSystem.load_game().get("Location", "res://scene managers/scenes/game_save.tscn")
	var target_scene = "res://scene managers/scenes/game_save.tscn"
	
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game scenes/main_menu.tscn")


##Save Deletion

func _on_delete_1_pressed() -> void:
	SaveFiles.path = save_file_1
	SaveSystem.delete_data()
	$File1/DeletedStatus1.visible = true
	await get_tree().create_timer(1.5).timeout
	$File1/DeletedStatus1.visible = false

func _on_delete_2_pressed() -> void:
	SaveFiles.path = save_file_2
	SaveSystem.delete_data()
	$File2/DeletedStatus2.visible = true
	await get_tree().create_timer(1.5).timeout
	$File2/DeletedStatus2.visible = false

func _on_delete_3_pressed() -> void:
	SaveFiles.path = save_file_3
	SaveSystem.delete_data()
	$File3/DeletedStatus3.visible = true
	await get_tree().create_timer(1.5).timeout
	$File3/DeletedStatus3.visible = false
	

# code for handling controller movement in the load screen

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if not using_controller:
			using_controller = true
			_update_focus_modes(true)
			$File1.grab_focus()
		
	elif event is InputEventMouse or event is InputEventKey:
		if using_controller:
			using_controller = false
			_update_focus_modes(false)
   


func _ready():
	if using_controller:
		_update_focus_modes(using_controller)
		
		
	$File1/Delete1.connect("focus_entered", _on_confirm_focus_entered1)
	$File1/Delete1.connect("focus_exited", _on_confirm_focus_exited1)
	$File2/Delete2.connect("focus_entered", _on_confirm_focus_entered2)
	$File2/Delete2.connect("focus_exited", _on_confirm_focus_exited2)
	$File3/Delete3.connect("focus_entered", _on_confirm_focus_entered3)
	$File3/Delete3.connect("focus_exited", _on_confirm_focus_exited3)

# a method to check wheter is a controller used or not, if it is, focus on the save states.
func _update_focus_modes(enable_focus: bool) -> void:
	var focus_mode = Control.FOCUS_ALL if enable_focus else Control.FOCUS_NONE
	$File1.focus_mode = focus_mode
	$File2.focus_mode = focus_mode
	$File3.focus_mode = focus_mode
	$File1/Delete1.focus_mode = focus_mode
	$File2/Delete2.focus_mode = focus_mode
	$File3/Delete3.focus_mode = focus_mode
	
	if not enable_focus:
		$File1/Delete1/Confirm.visible = false
		$File2/Delete2/Confirm.visible = false
		$File3/Delete3/Confirm.visible = false

func _on_confirm_focus_entered1() -> void:
	if using_controller:
		$File1/Delete1/Confirm.visible = true

func _on_confirm_focus_exited1() -> void:
	if using_controller:
		$File1/Delete1/Confirm.visible = false


func _on_confirm_focus_entered2() -> void:
	if using_controller:
		$File2/Delete2/Confirm.visible = true

func _on_confirm_focus_exited2() -> void:
	if using_controller:
		$File2/Delete2/Confirm.visible = false


func _on_confirm_focus_entered3() -> void:
	if using_controller:
		$File3/Delete3/Confirm.visible = true

func _on_confirm_focus_exited3() -> void:
	if using_controller:
		$File3/Delete3/Confirm.visible = false
 
