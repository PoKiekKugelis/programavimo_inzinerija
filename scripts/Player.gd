extends CharacterBody2D
class_name Player

@export var save_path: String
@export var stats: CharStats : set = set_character_stats
@onready var inventory_ui = $Inventory_UI
@onready var stamina: Stamina = $Stamina
@onready var movement_timer: Timer = $MovementTimer

const RUNNING_SPEED = 160.0
const SPEED = 80.0
const JUMP_VELOCITY = -400.0
var CAN_MOVE: bool = true

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

#tunrs back on the movement
func _on_movement_timer_timeout() -> void:
	CAN_MOVE = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("ui_jump") and is_on_floor() and CAN_MOVE == true:
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("left", "right")
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
	
	#signalas gautas is zaidejo hurtbox, ir siunciamas per pati player i pagrindine scena
	#signalas su savim nesasi prieso node, kad zinotu pries ka kovoja
func _on_hurt_box_enemy_touched(enemy: CharacterBody2D) -> void:
	enter_combat.emit(enemy)


func _on_health_health_depleted() -> void:
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
