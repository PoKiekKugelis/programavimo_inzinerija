extends CharacterBody2D
class_name Player
@onready var animated_sprite = $AnimatedSprite2D
@export var save_path: String
@export var stats: CharStats : set = set_character_stats
@onready var inventory_ui = $Inventory_UI
@onready var stamina: Stamina = $Stamina
@onready var movement_timer: Timer = $MovementTimer
const RUNNING_SPEED = 160.0
const SPEED = 80.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 350.0
const DASH_DISTANCE = 80.0  # Distance to dash
const GRAVITY = 980  # Gravity constant
var can_dash: bool = true
var is_dashing: bool = false
var dash_direction: int = 0
var dash_start_position: Vector2 = Vector2.ZERO
var CAN_MOVE: bool = true

# variables for double tap detection
var last_tap_direction: int = 0
var last_tap_time: float = 0
var double_tap_threshold: float = 0.25  # time window for double tap in seconds
var just_released: bool = true  # track if key was just released

signal enter_combat(enemy: CharacterBody2D)

func _ready() -> void:
	Inventory.set_player_reference(self)#set this node as player node so inventory knows

#Nustato energiją, kortų kiekį ir t.t.
func set_character_stats(value: CharStats) -> void:
	stats = value

#deals knockback to the player when hit
func _on_hurt_box_received_damage(damage: int) -> void:
	#Jeigu nepadare 0 damage, reiskia enemy, reiskia nereikia knockback
	#Veliau galbut items duos trap immunnity, tai turbut reikes pakeist
	if damage > 0:
		CAN_MOVE = false
		is_dashing = false  # Cancel dash if hit
		if velocity.x == 0:
			var LorR = [-1,1]
			LorR.shuffle()
			velocity.x = 800 * LorR.front()
		elif velocity.x < 0:
			velocity.x = 600
		else:
			velocity.x = -600
		velocity.y = -200	
		movement_timer.start()

#turns back on the movement
func _on_movement_timer_timeout() -> void:
	CAN_MOVE = true

func start_dash_cooldown() -> void:
	can_dash = false
	await get_tree().create_timer(1.0).timeout  # 1 second cooldown
	can_dash = true

func _physics_process(delta: float) -> void:
	
	# handle dashing
	if is_dashing:
		# check if we have reached the dash distance or have hit a wall
		if abs(position.x - dash_start_position.x) >= DASH_DISTANCE or is_on_wall():
			end_dash()
		else:
			velocity.x = DASH_SPEED * dash_direction
			#oOnly suspend gravity if on ground, or briefly when starting a dash
			if is_on_floor() or abs(position.x - dash_start_position.x) < 20:
				velocity.y = 0
			else:
				# apply reduced gravity during air dash
				velocity.y += GRAVITY * delta * 0.5
				
			var collision = move_and_slide()
			
			# end dash if we hit a wall
			if is_on_wall():
				end_dash()
				
			if collision:
				return  # still in dash, but handled collision
			
			return  # skip the rest of the physics process during dash
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	# Handle jump.
	if Input.is_action_pressed("ui_jump") and is_on_floor() and CAN_MOVE == true:
		velocity.y = JUMP_VELOCITY
		
	# Get direction from input
	var direction := Input.get_axis("left", "right")
	
	# Improved double-tap detection
	if Input.is_action_just_pressed("left"):
		handle_direction_tap(-1)
	elif Input.is_action_just_pressed("right"):
		handle_direction_tap(1)
	
	# Reset when no movement keys are pressed
	if direction == 0:
		just_released = true
	else:
		if just_released:
			just_released = false
			
	# Flip sprite based on direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# animacijos:DDDDDDDDDDDDDDDDDDDDDDDDDDDD
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")
	
	if direction != 0 && CAN_MOVE == true:
		stamina.set_is_moving(true)  
		if Input.is_action_pressed("ui_sprint") && stamina.stamina > 0:
			velocity.x = direction * RUNNING_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		stamina.set_is_moving(false)  
		velocity.x = move_toward(velocity.x, 0, SPEED)  
		
	move_and_slide()
	


# helper function to cleanly end the dash state
func end_dash() -> void:
	is_dashing = false
	# if in air, restore gravity effects immediately
	if not is_on_floor():
		velocity.y += GRAVITY * 0.016  # apply a small gravity impulse

# handle double-tap detection for dashing
func handle_direction_tap(direction: int) -> void:
	if !CAN_MOVE or is_dashing or !can_dash:
		return
		
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# check for double tap (same direction pressed twice within threshold time)
	if direction == last_tap_direction and current_time - last_tap_time < double_tap_threshold:
		# start dash
		is_dashing = true
		dash_direction = direction
		dash_start_position = position
		start_dash_cooldown()  # start the 1 second cooldown
		
		# reset tap detection
		last_tap_time = 0
		last_tap_direction = 0
	else:
		# record this tap for potential double tap detection
		last_tap_direction = direction
		last_tap_time = current_time
	
#signalas gautas is zaidejo hurtbox, ir siunciamas per pati player i pagrindine scena
#signalas su savim nesasi prieso node, kad zinotu pries ka kovoja
func _on_hurt_box_enemy_touched(enemy: CharacterBody2D) -> void:
	enter_combat.emit(enemy)
	
func _on_player_health_depleted() -> void:
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
