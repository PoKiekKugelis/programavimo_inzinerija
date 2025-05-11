extends RigidBody2D

@export var fall_delay: float = 0.5
@export var respawn_time: float = 3.0
@export var fall_speed: float = 100.0 

@onready var original_position: Vector2 = position
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var trigger_area: Area2D = $TriggerArea

var is_falling: bool = false

func _ready():
	freeze = true
	mass = 5.0
	gravity_scale = 0.5
	linear_damp = 0.8
	trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body is Player and !is_falling:
		start_fall_sequence()

func start_fall_sequence():
	is_falling = true
	
	# shake animation
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	var shake_duration = fall_delay * 0.8
	for i in 4:
		tween.tween_property(sprite, "position:x", 2.0, shake_duration/8)
		tween.tween_property(sprite, "position:x", -2.0, shake_duration/8)
	
	await get_tree().create_timer(fall_delay).timeout
	
	# enable physics but keep collision
	freeze = false
	
	
	# apply controlled downward velocity instead of full physics
	linear_velocity = Vector2.DOWN * fall_speed
	
	await get_tree().create_timer(respawn_time).timeout
	reset_platform()

func reset_platform():
	freeze = true
	position = original_position
	linear_velocity = Vector2.ZERO  # reset velocity
	is_falling = false
	sprite.position = Vector2.ZERO
