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
		elif inventory[i] != null and inventory[i]["type"] == item["type"] and inventory[i]["effect"] == item["effect"]:
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
func get_item_slot(slot):
	var item = {
	"quantity" : inventory[slot]["quantity"] as int,
	"type" : inventory[slot]["type"],
	"name" : inventory[slot]["name"],
	"texture" : inventory[slot]["texture"],
	"effect" : inventory[slot]["effect"],
	"scene_path" : inventory[slot]["scene_path"]
	}
	return item
	
# Spekit ka daro
func clear():
	inventory = []
	inventory.resize(21)

func remove_item():
	inventory_updated.emit()#TODO later

func set_player_reference(player):
	player_node = player#Initializes the player node for easier access
