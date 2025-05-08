extends TextureRect

@onready var entering_combat_sound: AudioStreamPlayer2D = $"../../EnteringCombatSound"

func _ready() -> void:
	_get_animation()
	_transition()
	
	#pirmas tween uztrunka sekunde kol pilnai uzdengia ekrana, todel
	#yra 1 sekundes timeout iki background pasirodymo	
	await get_tree().create_timer(1).timeout
	$"../../Background".visible = true
	$"../../BattleUI".visible = true
	
	# run the complete transition
	# need to clean up, because the animation screen was still there, blocking mouse inputs, even though it was over
	await _transition()
	queue_free()
	
func _get_animation():
	var number = (randi() % 12) + 1 #combat/assets/transitions yra 12 failu pavadinimais 1-12
	$".".texture = load("res://combat/assets/transitions/" + str(number) + ".png")

func _transition():	
	if !entering_combat_sound.playing:
		entering_combat_sound.play()
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) #kad pauzes metu butu animacija
	tween.tween_property(self, "material:shader_parameter/fill", 1, 1.0).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "material:shader_parameter/fill", 0, 1.0).set_delay(0.5).set_trans(Tween.TRANS_LINEAR)
	
	# wait for the entire animation to complete
	await tween.finished
