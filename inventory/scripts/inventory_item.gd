@tool
extends Node2D

@export var item_type = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_effect = ""
var scene_path: String = "res://scenes/inventory_item.tscn"

@onready var icon_sprite = $Sprite2D

var player_in_range = false

func _ready():
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture#For more convenient editing

func _process(delta):
	if Engine.is_editor_hint():
		icon_sprite.texture = item_texture#For more convenient editing
	if player_in_range and Input.is_action_just_pressed('pick_up'):#picks up the item by pressing "E"
		pickup_item()

func pickup_item():
	var item = {#Creates an item with all this info
		"quantity" : 1,
		"type" : item_type,
		"name" : item_name,
		"texture" : item_texture,
		"effect" : item_effect,
		"scene_path" : scene_path
	}
	if Inventory.player_node:#Simply adds the item
		Inventory.add_item(item)
		self.queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:#Checks if in pick up range
	if body.is_in_group("Player"):
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:#Checks if NOT in pick up range
	if body.is_in_group("Player"):
		player_in_range = false
