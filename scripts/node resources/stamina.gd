class_name Stamina
extends Node

signal stamina_changed  

@export var max_stamina: float
@export var stamina: float = max_stamina
@export var drain_rate: float = 8.0  
@export var recharge_rate: float = 5.0 

var is_moving: bool = false  


func _process(delta):
	# Unlimited stamina in the hub
	if (get_parent().get_parent().name == "Hub"):
		return
	
	if Input.is_action_pressed("ui_sprint") && stamina > 0 && is_moving:
		stamina -= drain_rate * delta  
		stamina = max(stamina, 0)  
		emit_signal("stamina_changed")  


	
	elif stamina < max_stamina && !Input.is_action_pressed("ui_sprint") || Input.is_action_pressed("ui_sprint") && !is_moving:
		stamina += recharge_rate * delta
		stamina = min(stamina, max_stamina)
		emit_signal("stamina_changed")


func set_is_moving(moving: bool) -> void:
	is_moving = moving
