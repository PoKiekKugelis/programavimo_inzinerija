extends CharacterBody2D

@onready var inventory_ui = $Inventory_UI

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	Inventory.set_player_reference(self)#set this node as player node also no delete pls

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
## ALL BELOW IS INVENTORY DO NOT DELETE. ABOVE IS AUTO GENERATED CODE FOR PLAYER MOVEMENT CAN DELETE/CHANGE
#inventory UI opens by pressing "I"
func _input(event):
	if event.is_action_pressed("ui_inventory"):
		inventory_ui.visible = !inventory_ui.visible
		
