##Global script
extends Node

var inventory = []#Creates item array
signal inventory_updated#A signal for recognizing when inventory was updated
var player_node: Node = null#Player node for ease of access
@onready var inventory_slot_scene = preload("res://inventory/scenes/inventory_slot.tscn")#Since it's a global script added a variable so all scripts can access it

func _ready():
	inventory.resize(21)#Sets the inventory size

func add_item(item):#Adds an item to the array
	for i in range(inventory.size()):#Loops through the whole inventory to check if item exists and where is the free space
		if inventory[i] == null:
			inventory[i] = item#If there are no such items in the inventory adds it.
			inventory_updated.emit()
			return true
		elif inventory[i] != null and inventory[i]["name"] == item["name"]:
			inventory[i]["quantity"] += item["quantity"]#If same item is already added it only adds +1
			inventory_updated.emit()#Emits the signal that the inventory was updated
			return true
	return false

# Grazina uzimtu slots kieki (item kieki)
# Tingiu tikrint as inventory.size() grazina uzimtus slots ar visada visus 21
func get_used_slots(): 
	var i = 0
	while(inventory[i] != null):
		i+=1;
	return i

# Sukonstruoja item'a su visa infromacija pagal inventoriaus slot'o indexa
func get_item_slot(slot: int):
	var item = {
	"quantity" : inventory[slot]["quantity"] as int,
	"type" : inventory[slot]["type"],
	"name" : inventory[slot]["name"],
	"texture" : inventory[slot]["texture"],
	"effect" : inventory[slot]["effect"],
	"scene_path" : inventory[slot]["scene_path"]
	}
	return item

# grazina tam tikra item pagal pavadinimas
func get_item_by_name(name: String):
	for i in range(get_used_slots()):
		var item = get_item_slot(i)
		if (item["name"] == name):
			return item
	return null 
	
func get_item_quantity(name: String):
	var item = get_item_by_name(name) 
	if(item is Dictionary and item.has("quantity")): # buvau priverstas sita naudot nes item != null neveikia
		return item["quantity"]
	return 0

# Spekit ka daro
func clear():
	inventory = []
	inventory.resize(21)

# 2 argumentai, pirmas yra item name, o antras yra kiek to item norim panaikint
# -1 reiskia panaikint ta item pilnai is inventory
func remove_item(name: String, amount: int):
	inventory_updated.emit()#TODO later 	signalai ne mano dalykas
	
	var item = get_item_by_name(name)
	var slot = -1
	for i in range(inventory.size()): 	#surandam slot su tokiu paciu item name
		if (inventory[i] != null and inventory[i]["name"] == name):
			slot = i
	
	if(slot != -1):
		if (amount == -1 or amount == inventory[slot]["quantity"]):
			inventory.remove_at(slot) 	# pilnai istrina indeksa
			inventory.append(null)		# todel reikia nauja null pridet
		elif (amount != -1):
			inventory[slot]["quantity"] -= amount
	
func set_player_reference(player):
	player_node = player#Initializes the player node for easier access
