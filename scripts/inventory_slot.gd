extends Control

@onready var item_tooltip: Control = $ItemTooltip
@onready var item_name: Label = $ItemTooltip/TextureRect/ItemName
@onready var icon: Sprite2D = $InnerBorder/ItemIcon
@onready var quantity: Label = $InnerBorder/ItemQuantity
@onready var item_type: Label = $ItemTooltip/TextureRect/ItemType
@onready var item_effect: Label = $ItemTooltip/TextureRect/ItemEffect

var item = null

func set_empty():#Sets the inventory slot as empty
	icon.texture = null
	quantity.text = ""
	
func set_item(new_item):#Sets the inventory slot as taken
	item = new_item
	icon.texture = item["texture"]
	quantity.text = str(item["quantity"])
	item_name.text = str(item["name"])
	item_type.text = str(item["type"])
	item_effect.text = str(item["effect"])

func _on_item_button_mouse_entered() -> void:
	if item != null:
		item_tooltip.visible = true


func _on_item_button_mouse_exited() -> void:
	if item != null:
		item_tooltip.visible = false
