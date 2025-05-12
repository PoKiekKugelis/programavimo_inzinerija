extends Control

# Pradiniai resursu skaiciai, kad butu galima disablint migtukus (>)
@onready var resourceQuantities = [Inventory.get_item_quantity("Pebble"),
	Inventory.get_item_quantity("Piece of Wood") ,Inventory.get_item_quantity("Rusted scrap")]

func _ready() -> void:
	# Iejus i menu, bus rasoma 0 ant visu labels, o zemiau nulio neisi, todel migtukai
	# disabled on ready (<)
	$RockButtons/RockDecrease.disabled = true
	$PaperButtons/PaperDecrease.disabled = true
	$MetalButtons/MetalDecrease.disabled = true
	
	#Paimam item kiekius is stockpile ir disable'inam buttons jeigu reikia
	_update_labels()
	_update_buttons()

func _on_convert_pressed() -> void:
	# Kiek materials norim gaut
	var materialQuantities = [int($RockButtons/RockNumber/Number.text), int($PaperButtons/PaperNumber/Number.text),
	int($MetalButtons/MetalNumber/Number.text)]
	
	# Paupdatina inventory
	_update_inventory(materialQuantities)
	
	# Kiek resursu liko
	resourceQuantities = [Inventory.get_item_quantity("Pebble"),
	Inventory.get_item_quantity("Piece of Wood"), Inventory.get_item_quantity("Rusted scrap")]
	
	# Paupdationa labels ir buttons
	_update_labels()
	_reset()

### Label'iu handle'inimas su rodykliu paspaudimais
## Rock
func _on_rock_decrease_pressed() -> void:
	$RockButtons/RockIncrease.disabled = false
	if ($RockButtons/RockNumber/Number.text == '1'):
		$RockButtons/RockDecrease.disabled = true
		
	$RockButtons/RockNumber/Number.text = str(int($RockButtons/RockNumber/Number.text) - 1)

func _on_rock_increase_pressed() -> void:
	$RockButtons/RockDecrease.disabled = false
	if resourceQuantities[0] < 3 * (int($RockButtons/RockNumber/Number.text) + 2):
		$RockButtons/RockIncrease.disabled = true
		
	$RockButtons/RockNumber/Number.text = str(int($RockButtons/RockNumber/Number.text) + 1)

## Paper
func _on_paper_decrease_pressed() -> void:
	$PaperButtons/PaperIncrease.disabled = false
	if ($PaperButtons/PaperNumber/Number.text == '1'):
		$PaperButtons/PaperDecrease.disabled = true
		
	$PaperButtons/PaperNumber/Number.text = str(int($PaperButtons/PaperNumber/Number.text) - 1)

func _on_paper_increase_pressed() -> void:
	$PaperButtons/PaperDecrease.disabled = false
	if resourceQuantities[1] < 3 * (int($PaperButtons/PaperNumber/Number.text) + 2):
		$PaperButtons/PaperIncrease.disabled = true
		
	$PaperButtons/PaperNumber/Number.text = str(int($PaperButtons/PaperNumber/Number.text) + 1)

## Metal
func _on_metal_decrease_pressed() -> void:
	$MetalButtons/MetalIncrease.disabled = false
	if ($MetalButtons/MetalNumber/Number.text == '1'):
		$MetalButtons/MetalDecrease.disabled = true
		
	$MetalButtons/MetalNumber/Number.text = str(int($MetalButtons/MetalNumber/Number.text) - 1)

func _on_metal_increase_pressed() -> void:
	$MetalButtons/MetalDecrease.disabled = false
	if resourceQuantities[2] < 3 * (int($MetalButtons/MetalNumber/Number.text) + 2):
		$MetalButtons/MetalIncrease.disabled = true
		
	$MetalButtons/MetalNumber/Number.text = str(int($MetalButtons/MetalNumber/Number.text) + 1)

## Pagalbines funkcijos, kurios palaiko tvarka
func _update_inventory(materialQuantities):
	if( materialQuantities[0] > 0):
		Inventory.add_item(Items.rock(materialQuantities[0]))
	if( materialQuantities[1] > 0):
		Inventory.add_item(Items.paper(materialQuantities[1]))
	if( materialQuantities[2] > 0):
		Inventory.add_item(Items.metal(materialQuantities[2]))
	
	Inventory.remove_item("Pebble", materialQuantities[0]*3)
	Inventory.remove_item("Piece of Wood", materialQuantities[1]*3)
	Inventory.remove_item("Rusted scrap", materialQuantities[2]*3)

func _update_labels():
	$RockLabels/Material/Number.text = "(" + str(Inventory.get_item_quantity("Rock")) + ")"
	$RockLabels/Resource/Number.text = "(" + str(Inventory.get_item_quantity("Pebble")) + ")"
	$PaperLabels/Material/Number.text = "(" + str(Inventory.get_item_quantity("Paper")) + ")"
	$PaperLabels/Resource/Number.text = "(" + str(Inventory.get_item_quantity("Piece of Wood")) + ")"
	$MetalLabels/Material/Number.text = "(" + str(Inventory.get_item_quantity("Metal")) + ")"
	$MetalLabels/Resource/Number.text = "(" + str(Inventory.get_item_quantity("Rusted scrap")) + ")"

func _update_buttons():
	if resourceQuantities[0] < 3: $RockButtons/RockIncrease.disabled = true
	else: $RockButtons/RockIncrease.disabled = false
	
	if resourceQuantities[1] < 3: $PaperButtons/PaperIncrease.disabled = true
	else: $PaperButtons/PaperIncrease.disabled = false
	
	if resourceQuantities[2] < 3: $MetalButtons/MetalIncrease.disabled = true
	else: $MetalButtons/MetalIncrease.disabled = false

# Grazina i pradine busena
func _reset():
	$RockButtons/RockNumber/Number.text = '0'
	$PaperButtons/PaperNumber/Number.text = '0'
	$MetalButtons/MetalNumber/Number.text = '0'
	$RockButtons/RockDecrease.disabled = true
	$PaperButtons/PaperDecrease.disabled = true
	$MetalButtons/MetalDecrease.disabled = true

func _on_visibility_changed() -> void:
	_reset()
	resourceQuantities = [Inventory.get_item_quantity("Pebble"),
	Inventory.get_item_quantity("Piece of Wood"), Inventory.get_item_quantity("Rusted scrap")]
	_update_buttons()
