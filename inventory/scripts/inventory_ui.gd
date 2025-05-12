extends Control

@onready var grid_container = $GridContainer
@onready var inventory_ui = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Inventory.inventory_updated.connect(_on_inventory_updated)#Doesn't call the function but simply connects to the signal in Inventory
	_on_inventory_updated()#"Fills" the inventory with empty slots
	$"../Label".text = "Inventory"
	if(owner.get_parent().name == "Hub"):
		$"../Label".text = "Stockpile"

func _on_inventory_updated():#"Fills" the inventory with slots
	clear_grid_container()
	for item in Inventory.inventory:
		var slot = Inventory.inventory_slot_scene.instantiate()
		grid_container.add_child(slot)
		if item != null:
			slot.set_item(item)#Adds a full item slot
		else:
			slot.set_empty()#Adds a null item slot

func clear_grid_container():#Clears the grid so the game starts with it empty
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()

func _input(event):#inventory UI opens by pressing "I"
	#Buvau vel grazines konfliktavima su pause_screen, tai pridejau 2 papildomus checks
	if event.is_action_pressed("ui_inventory") and (!get_tree().paused or inventory_ui.visible):	
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = !get_tree().paused
	if event.is_action_pressed("ui_cancel") and inventory_ui.visible:
		inventory_ui.visible = false
		get_tree().paused = false
		get_viewport().set_input_as_handled()
