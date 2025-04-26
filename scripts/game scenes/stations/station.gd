extends Node2D

@export var Type: String

# Turbut per daug visokius bools prikuriau
var resource: String
var depletion_chance: int = 0
var gathering_status: bool = false
var player_in_range: bool = false
var stop_signal: bool = false
var depleted: bool = false
var gathered: int = 0 	# Jeigu vidury 10 item loop'o nustosi gathering, ir veliau vel pradesi, tai
						# reikia apsaugot kad nebutu exploitinama visada po 9 items imant

func _ready() -> void:
	match Type: #Nustato item informacija, priklausomai nuo station scenos, kad man nereiketu atskiru skriptu rasyt
		"Rock":
			mine_station()
		"Wood":
			tree_station()
		"Scrap":
			scrapyard_station()
	
func mine_station():
	$"../Resource".item_type = "Resource"
	$"../Resource".item_name = "Rock shard"
	$"../Resource".item_texture = load("res://assets/sprites/Shard.png")
	$"../Resource".item_effect = "Can be turned to Rock"
	resource = "Rock"
	print(resource)
	
func tree_station():
	$"../Resource".item_type = "Resource"
	$"../Resource".item_name = "Piece of Wood"
	$"../Resource".item_texture = load("res://assets/sprites/Wood.png")
	$"../Resource".item_effect = "Can be turned to Paper"
	resource = "Wood"
	print(resource)

func scrapyard_station():
	$"../Resource".item_type = "Resource" 
	$"../Resource".item_name = "Rusted scrap"
	$"../Resource".item_texture = load("res://assets/sprites/Scrap.png")
	$"../Resource".item_effect = "Can be turned to Metal"
	resource = "Scrap"
	print(resource)
	
func gather_resource():
	$"Panel/Indicator".text = "+1 " + $"../Resource".item_name
	gathering_status = true
	stop_signal = false
	$Panel/Label.text = "Gathering..."
	for i in (len(range(10)) - gathered % 10):
		$"../Timer".start() #1 sekundes timeris
		await $"../Timer".timeout
		if(stop_signal):
			stop_gather()
			return
		var item = $"../Resource".duplicate() #reikia duplikato, nes item kode, jis nusizudo kai buna paimtas
		add_child(item)
		gathered += 1
		depletion_chance += 1
		item.pickup_item()
		print("Item added: ", resource)
		text_animation()
		check_depletion()
		
	depletion_chance += 5 #po 10 items, papildomi 5%, kad butu 15
	check_depletion()
	if(!depleted):
		gather_resource() # omg rekursija 😱, visai kaip algorai (apskaiciuokit sito metodo sudetinguma)

func check_depletion():
	var roll = randi() % 100 + 1
	if(depletion_chance >= roll):
		station_depleted()

func stop_gather():
	gathering_status = false
	$Panel/Label.text = "Resource has\ndepleted" if depleted else "Press \"E\" to gather"
	
func station_depleted():
	$Panel/Label.visible = true
	$Panel/Label.text = "Resource has\ndepleted"
	stop_signal = true
	depleted = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		$Panel.visible = true
		player_in_range = true
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	$Panel.visible = false
	player_in_range = false
	stop_signal = true
	
func _input(event: InputEvent) -> void:
	if !depleted:
		if(player_in_range and Input.is_action_just_pressed("pick_up") and !gathering_status):
			gather_resource()
			stop_signal = false
		elif(player_in_range and Input.is_action_just_pressed("pick_up") and gathering_status):
			stop_signal = true
			stop_gather()

func text_animation():
	var duplicate = $"Panel/Indicator".duplicate()
	$Panel.add_child(duplicate)
	duplicate.visible = true
	duplicate.position = $"Panel/Indicator".position
	var new_position = Vector2(duplicate.position[0], duplicate.position[1] - 20)
	var tween = get_tree().create_tween()
	#tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) #kad pauzes metu butu animacija
	tween.tween_property(duplicate, "position", new_position, 0.9)
	
	tween.tween_property(duplicate, "modulate:a", 0, 0.7)
	
	await tween.finished
	tween.kill()
	duplicate.queue_free()
	
	
	
	
	
