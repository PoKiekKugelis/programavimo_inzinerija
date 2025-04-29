extends Node


func _ready() -> void:
	Inventory.clear()
	Money.subtract_money(Money.get_money() - 30) # Turbut reiketu padaryt startig money metoda
	SaveSystem.delete_data()
	Events.in_combat_status_changed

func _on_restart_pressed() -> void:
	Events.restart_at_hub.emit()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game scenes/main_menu.tscn")
