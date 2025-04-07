extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("test")
	$LeaveHubView/LeaveHubScreen.visible = true
	get_tree().paused = true


func _on_add_pressed() -> void:
	Money.add_money(1)


func _on_subtract_pressed() -> void:
	Money.subtract_money(1)
