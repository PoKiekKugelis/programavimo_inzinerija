extends Node2D

@onready var in_range = false
@onready var conversion_ui: Control = $ConversionUI

func _ready() -> void:
	while(!(get_parent().get_child(-1).name == "Player")):
		await get_tree().create_timer(0.01).timeout
	conversion_ui.reparent(get_parent().get_child(-1).get_child(7))
	conversion_ui.position = conversion_ui.get_parent().position

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		in_range = true
		$Panel.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		in_range = false
		$Panel.visible = false
		if conversion_ui.visible:
			conversion_ui.visible = false

func _input(event: InputEvent) -> void:		
	if(in_range and Input.is_action_just_pressed("pick_up") and !conversion_ui.visible):
		conversion_ui.visible = true
	elif(in_range and Input.is_action_just_pressed("pick_up") and conversion_ui.visible):
		conversion_ui.visible = false
