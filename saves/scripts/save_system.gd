extends Node

@export var file_path: String 	# Save failo kelias
@onready var inventory = []
@onready var deck = []
var deck_string = []

#sukuria dict su dalykais kuriu reikia
func _save():
	var save_dict = {
		"Inventory": inventory,
		"Deck" : deck_string,
		"Money": Money.get_money()
	}
	return save_dict

# SUkuria json stringa su inventorium ir pinigais, struktura virsuj
func save_game():
	file_path = SaveFiles.path
	var save_game = FileAccess.open(file_path, FileAccess.WRITE)
	_update_inventory()
	_stringify_deck()
	var json_string = JSON.stringify(_save(), "\t")
	save_game.store_line(json_string)
	save_game.close()

# Veikia kaip paprastas save_game(), taciau neduplikuoja viso inventoriaus
# Buvo galima tiesiog paziuret kokioj scenoj dabar esam, bet eh
func save_game_in_hub():
	file_path = SaveFiles.path
	var save_game = FileAccess.open(file_path, FileAccess.WRITE)
	inventory = Inventory.get_inventory()
	_stringify_deck()
	var json_string = JSON.stringify(_save(), "\t")
	save_game.store_line(json_string)
	save_game.close()

#sitas tiesiog grazina dictionary, kurio values galima individualiai priskirt,
#veliau turbut padarysiu kad iskvietus sita metoda automatiskai padarytu viska, nes dabar
# nuejus i game.tscn, arba level1.tscn matysit kaip zaidejui tiesiog priskiriu "Health"
func load_game() -> Dictionary:
	file_path = SaveFiles.path
	Inventory.clear()
	if !FileAccess.file_exists(file_path):
		return {}

	var fd = FileAccess.open(file_path, FileAccess.READ)
	var json_string = fd.get_as_text()
	fd.close()

	var save_data = JSON.parse_string(json_string)
	if (save_data != null):
		Money.subtract_money(Money.get_money())

		if (save_data.has("Inventory")):
			var items = save_data["Inventory"]
			for data in items:
				Inventory.add_item(_dict_to_item(data))
		
		if inventory == []:
			_update_inventory() 
			
		if (save_data.has("Money")):
			Money.add_money(save_data["Money"])
		return save_data
	return {}

# Pa-update'a lokalu inventory, kuris yra rasomas i faila
func _update_inventory():
	for slot in range(Inventory.get_used_slots()):
		var item = Inventory.get_item_slot(slot)
		if _add_item(item) == 0:
			inventory.append(item)
	pass

# Grazina 1, kai buvo padidintas item'o quantity
# Grazina 0, kai to item nera, ir ji reikia prideti
func _add_item(new_item) -> int:
	for item in inventory:
		if item["name"] == new_item['name']:
			item["quantity"] += new_item["quantity"]
			return 1 
	return 0

func _dict_to_item(data):
	var item = {
		"quantity" : data["quantity"] as int,
		"type" : data["type"],
		"name" : data["name"],
		"texture" : data["texture"],
		"effect" : data["effect"],
		"scene_path" : data["scene_path"]
	}
	return item

func _stringify_deck():
	for card in deck.cards:
		deck_string.append(card.resource_path)

# Atidarant faila rasymui, jis yra overwrite'inimas, tai sitaip istrynt galima
func delete_data():
	file_path = SaveFiles.path
	var save_game = FileAccess.open(file_path, FileAccess.WRITE)
	save_game.close()
