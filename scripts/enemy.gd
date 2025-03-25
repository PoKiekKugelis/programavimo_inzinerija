extends CharacterBody2D

class_name TestEnemy

const speed = 20 # movement speed
var is_enemy_chase: bool = false  # for later inplementation
# probably wont need this but ok
@onready var health: Health = $Health

var dead: bool = false #For later inplementation
var taking_damage: bool = false #For later inplementation
var damage_to_deal = 20 
var is_dealing_damage: bool = false

var dir: Vector2
var dir_prev: Vector2
const gravity = 900
var is_roaming: bool = true #if true then moves around randomly. if false currently does nothing

func _ready() -> void:
	add_to_group("enemy")
	health = $Health
	
func _process(delta):
	if !is_on_floor(): #check is enemy is in the air
		velocity.y += gravity * delta
		velocity.x = 0
	move(delta)
	handle_animation()
	move_and_slide()
	

func move(delta):
	if !dead:
		if !is_enemy_chase:
			velocity += dir * speed * delta
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation(): # chooses right animation orientation when changing walking directions
	var anim_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		anim_sprite.play("walk")
		if dir.x == -1:
			anim_sprite.flip_h = false
		elif dir.x == 1:
			anim_sprite.flip_h = true # flips animation when walking to the right


func _on_direction_timer_timeout() -> void: # randomly chooses walking time and walk direction
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_enemy_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		if !dir_prev == dir: # prevents stopping momentum if enemy is moving in the same direction
			velocity.x = 0
		dir_prev = dir
	

func choose(array): # randomizes array and returns first
	array.shuffle()
	return array.front()
