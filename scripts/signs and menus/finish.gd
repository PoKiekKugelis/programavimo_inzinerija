extends Area2D

@export var target_level : PackedScene
func _on_body_entered(body):
	if (body.name == "Player"):
		
		#Sitas laikinai neveikia, kol neturim normalaus tree hierarchy
		SaveSystem.save_game(get_parent().scene_file_path, get_parent().get_child(-1))
		Events.run_won.emit()
