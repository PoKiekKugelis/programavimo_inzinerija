class_name HurtBox
extends Area2D

signal received_damage(damage: int)

#naudojamas kad nusiust signala game scenai, su priliesto prieso informacija
#player scena dalyvauja kaip tarpininkas

@export var health: Health
func _ready():
	connect("area_entered", _on_area_entered)

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox != null:
		health.health -= hitbox.damage
		received_damage.emit(hitbox.damage)
		
		#Jeigu buvo priliestas entity is "enemy" grupes, pereinama i combat
		if hitbox.owner.is_in_group("enemy") and !Events.in_combat:
			Events.enter_combat.emit(hitbox.owner)
			#pasibaigus pirmai transition animacijos daliai, nuzudo enemy is atminties
			await get_tree().create_timer(1).timeout
			
			##NEATKOMENTUOTI KOLKAS
			#hitbox.owner.free()
