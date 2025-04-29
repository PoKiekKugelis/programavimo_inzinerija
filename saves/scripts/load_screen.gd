extends Control

var save_file_1 = "res://saves/userData1.save"
var save_file_2 = "res://saves/userData2.save"
var save_file_3 = "res://saves/userData3.save"

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
