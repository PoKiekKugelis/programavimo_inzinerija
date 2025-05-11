extends StaticBody2D

@export var appear_time: float = 1.0  # how long it takes to appear
@export var disappear_time: float = 1.0  # how long it takes to disappear
@export var visible_duration: float = 2.0  # how long it stays visible
@export var invisible_duration: float = 2.0  # how long it stays invisible
@export var start_visible: bool = true  # whether platform starts visible
@export var auto_cycle: bool = true  # whether to cycle automatically

@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D
@onready var tween: Tween

func _ready():
	# set initial state
	if not start_visible:
		sprite.modulate.a = 0.0  # fully transparent
		collision_shape.disabled = true
	
	if auto_cycle:
		start_cycle()

func start_cycle():
	if start_visible:
		await get_tree().create_timer(visible_duration).timeout
		disappear()
	else:
		await get_tree().create_timer(invisible_duration).timeout
		appear()

func appear():
	# cancel any existing tween
	if tween:
		tween.kill()
	
	# create new tween for appearing
	tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 1.0, appear_time)
	
	# enable collision
	collision_shape.disabled = false
	
	if auto_cycle:
		await get_tree().create_timer(visible_duration).timeout
		disappear()

func disappear():
	# cancel any existing tween
	if tween:
		tween.kill()
	
	# create new tween for disappearing
	tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, disappear_time)
	
	# when animation completes, disable collision
	await tween.finished
	collision_shape.disabled = true
	
	if auto_cycle:
		await get_tree().create_timer(invisible_duration).timeout
		appear()
