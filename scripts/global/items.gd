extends Node

## Item aprasymai, kad man nereiketu ju rasyt skriptuose
# Ateity reikes visus items cia sudet
func rock(amount: int):
	return{
		"quantity" : amount,
		"type" : "Material",
		"name" : "Rock Shard",
		"texture" : "res://assets/sprites/Shard2.png",
		"effect" : "Used fro rock based upgrades/cards",
		"scene_path" : "res://scenes/inventory_item.tscn"
	}
	
func paper(amount: int):
	return{
		"quantity" : amount,
		"type" : "Material",
		"name" : "Paper",
		"texture" : "res://assets/sprites/Paper.png",
		"effect" : "Used for paper based upgrades/cards",
		"scene_path" : "res://scenes/inventory_item.tscn"
	}

func metal(amount: int):
	return{
		"quantity" : amount,
		"type" : "Material",
		"name" : "Metal",
		"texture" : "res://assets/sprites/Metal.png",
		"effect" : "Used for metal based upgrades/cards",
		"scene_path" : "res://scenes/inventory_item.tscn"
	}
