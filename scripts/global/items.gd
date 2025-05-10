extends Node

## Item aprasymai, kad man nereiketu ju rasyt skriptuose
# Ateity reikes visus items cia sudet
func rock(amount: int):
	return{
		"quantity" : amount,
		"type" : "Material",
		"name" : "Rock",
		"texture" : "res://assets/sprites/PlaceHolder.png",
		"effect" : "item_effect",
		"scene_path" : "res://scenes/inventory_item.tscn"
	}
	
func paper(amount: int):
	return{
		"quantity" : amount,
		"type" : "Material",
		"name" : "Paper",
		"texture" : "res://assets/sprites/PlaceHolder.png",
		"effect" : "item_effect",
		"scene_path" : "res://scenes/inventory_item.tscn"
	}

func metal(amount: int):
	return{
		"quantity" : amount,
		"type" : "Material",
		"name" : "Metal",
		"texture" : "res://assets/sprites/PlaceHolder.png",
		"effect" : "item_effect",
		"scene_path" : "res://scenes/inventory_item.tscn"
	}
