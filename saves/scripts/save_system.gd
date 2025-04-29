extends Node

@export var file_path: String 	# Save failo kelias
@onready var inventory = []

#sukuria dict su dalykais kuriu reikia
func _save():	
	var save_dict = {
		"Inventory": inventory,
		"Money": Money.get_money()
	}
	return save_dict
	
# SUkuria json stringa su inventorium ir pinigais, struktura virsuj
func save_game():
	file_path = SaveFiles.path
	var save_game = FileAccess.open(file_path, FileAccess.WRITE)
	stringify_inventory()
	var json_string = JSON.stringify(_save())
	save_game.store_line(json_string)
	save_game.close()

#sitas tiesiog grazina dictionary, kurio values galima individualiai priskirt,
#veliau turbut padarysiu kad iskvietus sita metoda automatiskai padarytu viska, nes dabar
# nuejus i game.tscn, arba level1.tscn matysit kaip zaidejui tiesiog priskiriu "Health"
func load_game() -> Dictionary:
	file_path = SaveFiles.path
	#var save_data: Dictionary = {}
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
		
		if (save_data.has("Money")):
			Money.add_money(save_data["Money"])

		print(save_data)
		return save_data
	return {}

# Pavercia inventoriu i stringu masyva
func stringify_inventory():
	inventory.clear() # Kad neduplikuotu ant virsaus
	for slot in range(Inventory.get_used_slots()):
		inventory.append(Inventory.get_item_slot(slot))
	
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

# Atidarant faila rasymui, jis yra overwrite'inimas, tai sitaip istrynt galima
func delete_data():
	file_path = SaveFiles.path
	var save_game = FileAccess.open(file_path, FileAccess.WRITE)
	save_game.close()
