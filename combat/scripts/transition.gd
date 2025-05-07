extends TextureRect

@onready var entering_combat_sound: AudioStreamPlayer2D = $"../../EnteringCombatSound"

func _ready() -> void:
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
	

func _transition():	
	if !entering_combat_sound.playing:
		entering_combat_sound.play()
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) #kad pauzes metu butu animacija
	tween.tween_property(self, "material:shader_parameter/fill", 1, 1.0).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "material:shader_parameter/fill", 0, 1.0).set_delay(0.5).set_trans(Tween.TRANS_EXPO)
	
	# wait for the entire animation to complete
	await tween.finished
