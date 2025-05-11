class_name BoulderHitBox
extends Area2D

@export var damage: int = 1 : set = set_damage, get = get_damage
var hit_owner = null  # Will be set in ready

func _ready():
	owner = get_parent()
	hit_owner = owner  # Store reference to the boulder or whatever owns this
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is Player:
		print("Boulder hit player!")
		body._on_hurt_box_received_damage(damage)

		# Bounce the boulder slightly to left or right
		if hit_owner and hit_owner is RigidBody2D:
			var direction = 1
			if hit_owner.global_position.x < body.global_position.x:
				direction = -1
			hit_owner.apply_impulse(Vector2.ZERO, Vector2(20000 * direction, -1000))
			
func set_damage(value: int):
	damage = value
	
func get_damage() -> int:
	return damage
