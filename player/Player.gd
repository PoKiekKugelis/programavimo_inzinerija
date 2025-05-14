extends CharacterBody2D
class_name Player

@export var save_path: String
@export var char_stats: CharStats : set = set_character_stats

@onready var health: Health = $Health
@onready var stamina: Stamina = $Stamina
@onready var movement_timer: Timer = $MovementTimer
@onready var animated_sprite = $AnimatedSprite2D
@onready var deck_button: CardDeckOpen = %DeckButton
@onready var deck_view: CardDeckView = $CardDeckView/DeckView

@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var dash_sound: AudioStreamPlayer2D = $DashSound
@onready var landing_sound: AudioStreamPlayer2D = $LandingSound
@onready var walking_sound: AudioStreamPlayer2D = $WalkingSound
@onready var sprinting_sound: AudioStreamPlayer2D = $SprintingSound



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
var jumped: bool = false
var running: bool = false

# variables for double tap detection
var last_tap_direction: int = 0
var last_tap_time: float = 0
var double_tap_threshold: float = 0.25  # time window for double tap in seconds
var just_released: bool = true  # track if key was just released

func _ready() -> void:
	Inventory.set_player_reference(self)#set this node as player node so inventory knows
	if $Health:
		GlobalHealth.set_health_instance(health)
	else:
		push_error("Health node not found in Player scene!")
	$PlayerUI/HealthBar.setup_health_bar(health)
	$PlayerUI/StaminaBar.setup_stamina_bar()

func set_character_stats(value: CharStats) -> void:
	char_stats = value

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
	dash_sound.play()
	can_dash = false
	await get_tree().create_timer(1.0).timeout  # 1 second cooldown
	can_dash = true
 
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		landing_sound.play()
		# Handle jump.
	if Input.is_action_pressed("ui_jump") and is_on_floor() and CAN_MOVE == true:
		velocity.y = JUMP_VELOCITY
		jump_sound.play()


	# Get direction from input
	var direction := Input.get_axis("left", "right")
	
	# Improved double-tap detection
	if Input.is_action_just_pressed("left"):
		handle_direction_tap(-1)
	elif Input.is_action_just_pressed("right"):
		handle_direction_tap(1)
	
	if is_on_floor() and CAN_MOVE and direction != 0 and running == true:
		if not sprinting_sound.playing:
			sprinting_sound.play()
	else:
		if sprinting_sound.playing:
			sprinting_sound.stop()
	
	
	if is_on_floor() and CAN_MOVE and direction != 0 and running == false:
		if not walking_sound.playing:
			walking_sound.play()
	else:
		if walking_sound.playing:
			walking_sound.stop()
	
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
	# handle dashing
	if is_dashing:
		
		# check if we have reached the dash distance or have hit a wall
		if abs(position.x - dash_start_position.x) >= DASH_DISTANCE or is_on_wall():
			end_dash()
			
		else:
			velocity.x = DASH_SPEED * dash_direction
			
			if Input.is_action_pressed("ui_jump") and is_on_floor():
				jumped = true
			
			
			# apply reduced gravity during air dash
			if not is_on_floor() && abs(position.x - dash_start_position.x) > 75 && jumped == false:
				velocity.y += GRAVITY * delta * 0.5
				
			
			var collision = move_and_slide()
			
			# end dash if we hit a wall
			if is_on_wall():
				end_dash()
				
			if collision:
				return  # still in dash, but handled collision
			
			return  # skip the rest of the physics process during dash
		
		
	# animacijos:DDDDDDDDDDDDDDDDDDDDDDDDDDDD
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle_cat")
		else:
			animated_sprite.play("walk_cat")
			
			
	else:
		animated_sprite.play("jump_cat")
	
	if direction != 0 && CAN_MOVE == true:
		stamina.set_is_moving(true)  
		if Input.is_action_pressed("ui_sprint") && stamina.stamina > 0:
			running = true
			velocity.x = direction * RUNNING_SPEED
		else:
			running = false
			velocity.x = direction * SPEED
	else:
		stamina.set_is_moving(false)  
		velocity.x = move_toward(velocity.x, 0, SPEED)  
		
	move_and_slide()

# helper function to cleanly end the dash state
func end_dash() -> void:
	is_dashing = false
	jumped = false;
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

func _on_health_health_depleted() -> void:
	if Events.in_combat:
		Events.player_died_in_combat.emit()
		return
	Events.player_died.emit()


func connect_deck():
	if char_stats:
		deck_button.card_deck = char_stats.deck#prijungia pradinę kaladę, kad žinotu kiek kortų turi
		deck_view.card_deck = char_stats.deck#prijungia kaladę, kad žinotų, kokias kortas rodyti
		deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))#prijungia kaip mygtuką
		#bet reikės pridėti, kad hover pakeistų spalvą truputį ar kažką, kad aiškiau būtų
