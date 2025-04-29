extends Node2D

var player_in_range = false


func _process(delta):
	if player_in_range and Input.is_action_just_pressed('pick_up'):#picks up the item by pressing "E"
		$"../proceed_sign_view/proceed_sign_screen".visible = true
		get_tree().paused = true
		
		# handle controller support
		var go_to_hub_button = $"../proceed_sign_view/proceed_sign_screen/HBoxContainer/go_to_hub"
		go_to_hub_button.call_deferred("grab_focus")




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
