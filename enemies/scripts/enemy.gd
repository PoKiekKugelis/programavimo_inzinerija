extends CharacterBody2D
class_name TestEnemy

@onready var health: Health = $Health
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var intent_ui: IntentUI = $IntentUI
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


@export var stats: EnemyStats

const speed = 20 # movement speed
const gravity = 900
var is_enemy_chase: bool = false  # for later inplementation
var dead: bool = false #For later inplementation
var taking_damage: bool = false #For later inplementation
var is_dealing_damage: bool = false
var dir: Vector2
var dir_prev: Vector2
var is_roaming: bool = true #if true then moves around randomly. if false currently does nothing
var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action

func _ready() -> void:
	add_to_group("enemy")
	health = $Health
	health.health_depleted.connect(_on_death)

func _on_death() -> void:
	dead = true
	$AnimatedSprite2D.play("death")
	await $AnimatedSprite2D.animation_finished
	queue_free()

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
	if dead:
		return
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

func setup_ai() -> void:
	if enemy_action_picker:
		enemy_action_picker.queue_free()
	var new_action_picker: EnemyActionPicker = stats.ai.instantiate()
	add_child(new_action_picker)
	enemy_action_picker = new_action_picker
	enemy_action_picker.enemy = self

func update_action() -> void:
	if not current_action:
		current_action = enemy_action_picker.get_action()
		return
	var new_conditional_action := enemy_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action

func do_turn() -> void:
	if not current_action:
		return
	current_action.perform_action()

func set_current_action(value) -> void:
	current_action = value
	if current_action:
		intent_ui.update_intent(current_action.intent)
