class_name Health
extends Node

# variable and signal for the shield card
var shield: int = 0
signal shield_changed(diff: int) 

# signals for health changes
signal max_health_changed(diff: int)  # emitted when max health changes
signal health_changed(diff: int)      # emitted when current health changes  
signal health_depleted                # emitted when health reaches 0

# configuration variables
@export var max_health: int     # maximum health value
@export var immortality: bool = false : set = set_immortality, get = get_immortality
@onready var health: int = max_health : set = set_health, get = get_health  # current health

@onready var healing_sound: AudioStreamPlayer2D = $"../HealingSound"
@onready var impact_sound: AudioStreamPlayer2D = $"../ImpactSound"
@onready var hit_sound: AudioStreamPlayer2D = $"../HitSound"
@onready var death_sound: AudioStreamPlayer2D = $"../DeathSound"

const WHITE_SPRITE_MATERIAL := preload("res://assets/combat assets/white_sprite_material.tres")
const GREEN_HEALING_MATERIAL := preload("res://assets/combat assets/green_healing_material.tres")

# timer for temporary immortality
var immortality_timer: Timer = null

# sets maximum health with validation
func set_max_health(value: int):
	# ensure health never goes below 1
	var clamped_value = 1 if value <= 0 else value
	
	# only emit signal if value actually changed
	if not clamped_value == max_health:
		var difference = clamped_value - max_health
		max_health = value
		max_health_changed.emit(difference)
		
		# adjust current health if over new max
		if health > max_health:
			health = max_health

# gets maximum health value
func get_max_health() -> int:
	return max_health

# sets current health with validation
func set_health(value: int):
	
	# block damage if immortal
	if value < health and immortality:
		print("Damage blocked due to immortality!")
		return
		
	# clamp value between 0 and max health
	var clamped_value = clampi(value, 0, max_health)
	
	# only update if value changed
	if clamped_value != health:
		var difference = clamped_value - health
		health = clamped_value
		health_changed.emit(difference)
		if difference <= -1:
			play_player_hit_sound()
		if Events.in_combat and difference < 0:# A shaking animation when damage taken
			take_damage_animation()
		if Events.in_combat and difference > 0:# A shaking animation when damage taken
			heal_animation()
		if !Events.in_combat:
			if health <= 0: health_depleted.emit()# check for death

func play_enemy_hit_sound() -> void:
	var who = owner
	if who is TestEnemy:
		impact_sound.play()

func play_player_hit_sound() -> void:
	var who = owner
	if who is Player:
		if !hit_sound.playing:
			hit_sound.play()


func take_damage_animation() -> void:
	var to_shake = owner
	if to_shake is Player:
		to_shake = get_tree().get_first_node_in_group("combat_player")
	if to_shake is TestEnemy:
		to_shake = get_parent().get_node("AnimatedSprite2D")
	
	to_shake.material = WHITE_SPRITE_MATERIAL
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_callback(Shaker.shake.bind(to_shake,12,0.15))
	tween.tween_interval(0.17)
	
	tween.finished.connect(func():
		to_shake.material = null
		if health <= 0: health_depleted.emit()# check for death
		)

func heal_animation() -> void:
	var to_heal = owner
	if to_heal is Player:
		to_heal = get_tree().get_first_node_in_group("combat_player")
	if to_heal is TestEnemy:
		to_heal = get_parent().get_node("AnimatedSprite2D")
	
	to_heal.material = GREEN_HEALING_MATERIAL
	
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(to_heal, "material:shader_parameter/fade_speed", -1.0, 0.3)
	tween.tween_property(to_heal, "material:shader_parameter/fade_speed", -0.3, 0.3)
	
	tween.finished.connect(func():
		to_heal.material = null
		if health <= 0: health_depleted.emit()# check for death
		)

# handles full and partial shield use, then applies leftover damage.
func receive_damage(amount: int):
	play_player_hit_sound()
	play_enemy_hit_sound()
	if shield > 0:
		if amount <= shield:
			shield -= amount
			shield_changed.emit()
			return
		else:
			amount -= shield
			shield = 0
			shield_changed.emit()
	set_health(health - amount)

# gets current health value
func get_health():
	return health
	
# sets immortality state    
func set_immortality(value: bool):
	immortality = value
	
# grants temporary immortality    
func set_temporary_immortality(time: float):
	# initialize timer if doesn't exist
	if immortality_timer == null:
		immortality_timer = Timer.new()
		immortality_timer.one_shot = true
		add_child(immortality_timer)
		
		# clean up previous connections
		if immortality_timer.timeout.is_connected(set_immortality):
			immortality_timer.timeout.disconnect(set_immortality)
		
		# configure timer
		immortality_timer.set_wait_time(time)
		immortality_timer.timeout.connect(set_immortality.bind(false))
		immortality = true
		immortality_timer.start()

# gets current immortality state
func get_immortality() -> bool:
	return immortality

# emit signals for shield card updates
func apply_shield(amount: int):
	shield = amount
	shield_changed.emit()

func clear_shield():
	shield = 0
	shield_changed.emit()

func apply_heal(amount: int):
	set_health(health + amount)
	print(healing_sound)
	if amount > 0 and healing_sound != null:
		healing_sound.play()
