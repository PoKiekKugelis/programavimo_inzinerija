extends Area2D


func _on_body_entered(body):
	print("Body entered:", body.name)
	if (body.name == "Player"):
		print("Changing scene...")
		get_tree().change_scene_to_file("res://scenes/level_complete.tscn")
