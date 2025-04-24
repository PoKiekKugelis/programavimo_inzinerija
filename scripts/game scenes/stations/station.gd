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
	$"../Resource".item_name = "Pebble"
	$"../Resource".item_texture = load("res://assets/sprites/mine_station.png")
	$"../Resource".item_effect = "Can be turned to rock"
	resource = "Rock"
	print(resource)
	
func tree_station():
	$"../Resource".item_type = "Resource"
	$"../Resource".item_name = "Piece of Wood"
	$"../Resource".item_texture = load("res://assets/sprites/mine_station.png")
	$"../Resource".item_effect = "Can be turned to paper"
	resource = "Wood"
	print(resource)

func scrapyard_station():
	$"../Resource".item_type = "Resource" 
	$"../Resource".item_name = "Rusted scrap"
	$"../Resource".item_texture = load("res://assets/sprites/mine_station.png")
	$"../Resource".item_effect = "Can be turned to metal"
	resource = "Scrap"
	print(resource)
	
func gather_resource():
	gathering_status = true
	stop_signal = false
	$Panel/Label.text = "Gathering..."
	for i in (len(range(10)) - gathered % 10):
		$"../Timer".start()	#1 sekundes timeris
		await $"../Timer".timeout
		if(stop_signal):
			stop_gather()
			return
		var item = $"../Resource".duplicate() #reikia duplikato, nes item kode, jis nusizudo kai buna paimtas
		add_child(item)
		gathered +=1
		item.pickup_item()
		print("Item added: ", resource)
		
	depletion_chance += 15
	var roll = randi() % 100 + 1
	print("Depletion chance: ", depletion_chance)
	if(depletion_chance >= roll):
		station_depleted()
	else:
		gather_resource() # omg rekursija 😱, visai kaip algorai (apskaiciuokit sito metodo sudetinguma)
		
func stop_gather():
	gathering_status = false
	$Panel/Label.text = "Press \"E\" to gather"
	
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
		elif(player_in_range and Input.is_action_just_pressed("pick_up") and gathering_status):
			stop_signal = true
			stop_gather()
