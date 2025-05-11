extends RigidBody2D
class_name Boulder

var has_started_rolling := false
var destroy_timer: Timer

func _ready():
	set_gravity_scale(0)
	visible = false  # starts invisible until activated
	
	# setup 5-second self-destruct timer
	destroy_timer = Timer.new()
	destroy_timer.wait_time = 5.0
	destroy_timer.one_shot = true
	destroy_timer.connect("timeout", queue_free)
	add_child(destroy_timer)

func activate():
	visible = true
	set_gravity_scale(1.0)  # enable gravity to make it fall
	
	# configure physics material for bouncy behavior
	var material = PhysicsMaterial.new()
	material.bounce = 0.4
	material.friction = 0.2
	physics_material_override = material
	
	destroy_timer.start()  # start countdown to destruction

func start_rolling():
	if !has_started_rolling:
		has_started_rolling = true
		# apply random left/right impulse to start rolling
		var direction = [-1, 1].pick_random()
		apply_central_impulse(Vector2(direction * 100, 0))
		physics_material_override.friction = 0.1  # reduce friction for better rolling

# handles collisions with other physics bodies
func _on_body_entered(body: Node) -> void:
	if body is Player:
		# apply random upward bounce when hitting player
		var bounce_direction = Vector2(
			randf_range(-1, 1),  # random horizontal direction
			randf_range(-0.5, -1)  # always bounce upward
		).normalized()
		apply_central_impulse(bounce_direction * 400)

# triggered when entering the rolling activation area
func _on_boulder_rolling_trigger_body_entered(body: Node2D) -> void:
	if body == self:  # only activate if it is this boulder
		start_rolling()
