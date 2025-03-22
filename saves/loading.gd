extends TextureRect

func _on_control_button_pressed() -> void:
	$"..".visible = true
	_transition()
	
	#pirmas tween uztrunka sekunde kol pilnai uzdengia ekrana, todel
	#yra 1 sekundes timeout iki background pasirodymo
	await get_tree().create_timer(1).timeout
	$"../Label".visible = true
	$"../Icon".visible = true
	icon_rotation()


func _transition():	
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) #kad pauzes metu butu animacija
	tween.tween_property(self, "material:shader_parameter/fill", 1, 1.0).set_trans(Tween.TRANS_EXPO)
	#tween.tween_property(self, "material:shader_parameter/fill", -0.1, 1.0).set_delay(4.5).set_trans(Tween.TRANS_EXPO)

func icon_rotation():
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property($"../Icon", "rotation", 15, 5)
	pass
