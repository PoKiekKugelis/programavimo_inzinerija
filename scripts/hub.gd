extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("test")
	$LeaveHubView/LeaveHubScreen.visible = true
	get_tree().paused = true
