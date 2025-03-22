extends Area2D

@export var target_level : PackedScene

func _on_body_entered(body):
	if (body.name == "Player"):
		
		SaveSystem.save_game(get_parent().scene_file_path, get_parent().get_child(1))
		get_tree().change_scene_to_packed(target_level)
