class_name HitBox
extends Area2D

@export var damage: int = 1 : set = set_damage, get = get_damage
var hit_owner = null  # Will be set in ready

func _ready():
	# Get the parent as the owner
	owner = get_parent()

func set_damage(value: int):
	damage = value
	
func get_damage() -> int:
	return damage
