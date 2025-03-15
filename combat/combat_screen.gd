extends Control

@export var player: Sprite2D
@export var enemy: AnimatedSprite2D

func _ready() -> void:
	#viska pradeda daryt uz sekundes, nes pirma animacijos dalis trunka sekunde
	await get_tree().create_timer(1).timeout
	load_entities()

#panasu kad nebereikalingas metodas, bet gal prireiks ateity
func load_entities():
	player.visible = true
	enemy.visible = true
	set_transformations()
	
#padidina sprites ir padeda i pakankamai gera vieta
func set_transformations():
	player.position = Vector2(300, 450)
	enemy.position = Vector2(900, 500)
	
	player.scale = Vector2(1.5,1.5)
	enemy.scale = Vector2(3, 3)
	
