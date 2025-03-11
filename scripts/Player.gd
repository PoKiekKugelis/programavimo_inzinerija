extends CharacterBody2D

@onready var inventory_ui = $Inventory_UI
@onready var stamina: Stamina = $Stamina
@onready var movement_timer: Timer = $MovementTimer

const RUNNING_SPEED = 160.0
const SPEED = 80.0
const JUMP_VELOCITY = -400.0
const KNOCKBACK = 300.0
var CAN_MOVE: bool = true

func _ready() -> void:
	Inventory.set_player_reference(self)#set this node as player node also no delete pls

#deals knockback to the player when hit
func _on_hurt_box_received_damage(damage: int) -> void:
	CAN_MOVE = false
	var knockback_dir = Vector2.UP * KNOCKBACK
	velocity = knockback_dir
	movement_timer.start()

#tunrs back on the movement
func _on_movement_timer_timeout() -> void:
	CAN_MOVE = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_jump") and is_on_floor() and CAN_MOVE == true:
		velocity.y = JUMP_VELOCITY


	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0 and CAN_MOVE == true:
		stamina.set_is_moving(true)  
		if Input.is_action_pressed("ui_sprint") && stamina.stamina > 0:
			velocity.x = direction * RUNNING_SPEED  
		else:
			velocity.x = direction * SPEED  
	else:
		stamina.set_is_moving(false)  
		velocity.x = move_toward(velocity.x, 0, SPEED)  

	move_and_slide()
## ALL BELOW IS INVENTORY DO NOT DELETE. ABOVE IS AUTO GENERATED CODE FOR PLAYER MOVEMENT CAN DELETE/CHANGE
#inventory UI opens by pressing "I"
func _input(event):
	if event.is_action_pressed("ui_inventory"):
		inventory_ui.visible = !inventory_ui.visible
		
