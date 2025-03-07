extends Control

@onready var icon: Sprite2D = $InnerBorder/ItemIcon
@onready var quantity: Label = $InnerBorder/ItemQuantity
var item = null

func set_empty():#Sets the inventory slot as empty
	icon.texture = null
	quantity.text = ""
	
func set_item(new_item):#Sets the inventory slot as taken
	item = new_item
	icon.texture = item["texture"]
	quantity.text = str(item["quantity"])
