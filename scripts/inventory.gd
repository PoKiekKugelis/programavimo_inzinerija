##Global script
extends Node

var inventory = []#Creates item array
signal inventory_updated#A signal for recognizing when inventory was updated
var player_node: Node = null#Player node for ease of access
@onready var inventory_slot_scene = preload("res://scenes/inventory_slot.tscn")#Since it's a global script added a variable so all scripts can access it

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

func remove_item():
	inventory_updated.emit()#TODO later

func set_player_reference(player):
	player_node = player#Initializes the player node for easier access
