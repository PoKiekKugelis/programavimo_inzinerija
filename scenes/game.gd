extends Node2D

#vietoj to kad pilnai pakeist scena, tiesiog instantiate naudojuj, nes change_scene
#neissaugotu dabartines map state, tai todel tiesiog pauze padarau
#(teoriskai turbut butu galima combat scena kaip child pridet, bet idk, kolkas veikia)
#dar turbut reiketu isskaidyt i mazesnius metodus, kad readability butu geresnis
#krc nezinau kas cia vyksta
# skull emoji 💀
func _on_player_enter_combat(enemy: CharacterBody2D) -> void:
	var combat_scene: PackedScene = preload("res://combat/combat_screen.tscn")
	var combat_instance = combat_scene.instantiate()
	var player = $Player/Sprite2D.duplicate()
	var enemySprite = enemy.get_child(2).duplicate() #pasiemu animated sprite
	#veliau turbut reiketu pati enemy pasiimt, bet kad nuo map nenukristu padaryt
	#kai bus imamas pats enemy, tai tada turbut reikes jo direction uzrakint ir uzdet idle animation
	combat_instance.add_child(player)
	combat_instance.add_child(enemySprite)
	combat_instance.player = player
	combat_instance.player.visible = false
	combat_instance.enemy = enemySprite
	combat_instance.enemy.visible = true 
	get_tree().paused = true
	get_tree().root.add_child(combat_instance)
	#dabar po penkiu sekundziu tiesiog panaikinu combat scena ir priesa ir atminties
	#poto kai bus combat, tai speju su signalais bus galima kazkaip padaryt 
	#kad on_victory and on_defeat tam tikrus dalykus padaryt
	await get_tree().create_timer(5).timeout
	combat_instance.free()
	enemy.free()
	get_tree().paused = false
