extends Node

@export var file_path: String 	# Save failo kelias

#sukuria dict su dalykais kuriu reikia
func save(current_scene, health):	
	#inventorius ateities problema (turbut rytojaus)
	var save_dict = {
		"Location": current_scene,
		"Health": health
	}
	return save_dict
	
#uhh, uhm uhhh, erm, paduodi scena ir zaideja, ir issaugo i faila
func save_game(current_scene: String, player: CharacterBody2D) -> void:
	file_path = SaveFiles.path
	var save_game = FileAccess.open(file_path, FileAccess.WRITE)
	var health = player.get_child(0).health
	var json_string = JSON.stringify(save(current_scene, health))
	save_game.store_line(json_string)
	save_game.close()

#sitas tiesiog grazina dictionary, kurio values galima individualiai priskirt,
#veliau turbut padarysiu kad iskvietus sita metoda automatiskai padarytu viska, nes dabar
# nuejus i game.tscn, arba level1.tscn matysit kaip zaidejui tiesiog priskiriu "Health"
func load_game() -> Dictionary:
	file_path = SaveFiles.path
	var save_data: Dictionary = {}
	if !FileAccess.file_exists(file_path):
		return {}

	var save_game = FileAccess.open(file_path, FileAccess.READ)
	
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parsed = json.parse(json_string)
		save_data = json.get_data()
	
	save_game.close()
	return save_data

# Atidarant faila rasymui, jis yra overwrite'inimas, tai sitaip istrynt galima
func delete_data():
	file_path = SaveFiles.path
	var save_game = FileAccess.open(file_path, FileAccess.WRITE)
	save_game.close()
