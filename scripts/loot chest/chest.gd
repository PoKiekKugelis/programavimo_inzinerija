extends AnimatedSprite2D

@onready var animation_player = $AnimationPlayer

var player_in_range: bool = false
var is_open: bool = false
var resource: String
var Type: int
var PEBBLE_RANGE = range(1, 11)
var WOOD_RANGE = range(11, 21)
var SCRAP_RANGE = range(21, 31)
var COIN_RANGE = range(31, 46)
var inv_item: bool = false
var icon: Texture
var spawn_pos

func pebble():
	$Resource.item_type = "Resource"
	$Resource.item_name = "Pebble"
	$Resource.item_texture = load("res://assets/sprites/Pebble.png")
	$Resource.item_effect = "Can be turned to Rock shards"
	resource = "Pebble"
	inv_item = true

func wood():
	$Resource.item_type = "Resource"
	$Resource.item_name = "Piece of Wood"
	$Resource.item_texture = load("res://assets/sprites/Wood.png")
	$Resource.item_effect = "Can be turned to Paper"
	resource = "Wood"
	inv_item = true

func scrap():
	$Resource.item_type = "Resource" 
	$Resource.item_name = "Rusted scrap"
	$Resource.item_texture = load("res://assets/sprites/Scrap.png")
	$Resource.item_effect = "Can be turned to Metal"
	resource = "Scrap"
	inv_item = true

func coins():
	await get_tree().create_timer(1.7).timeout
	var amount = randi() % 10 + 1
	Money.add_money(amount)
	print("Item added: Coin"," ", amount)
	icon = load("res://assets/sprites/coin.png")
	spawn_pos = $Area2D.position
	_show_loot_popup(icon, spawn_pos, inv_item)

func _process(delta) -> void:
	if player_in_range and Input.is_action_just_pressed('pick_up') and not is_open:
		is_open = true
		animation_player.play("opening")
		Type = randi() % 45 + 1
		if Type in PEBBLE_RANGE:
			pebble()
		elif Type in WOOD_RANGE:
			wood()
		elif Type in SCRAP_RANGE:
			scrap()
		elif Type in COIN_RANGE:
			coins()
		
		await get_tree().create_timer(1.7).timeout
		_give_item()

func _give_item():
	if inv_item:
		icon = $Resource.item_texture
		spawn_pos = $Area2D.position
		_show_loot_popup(icon, spawn_pos, inv_item)
		var item = $Resource.duplicate() #reikia duplikato, nes item kode, jis nusizudo kai buna paimtas
		add_child(item)
		var count = 0
		for i in range(randi() % 5 + 1):
			item.pickup_item()
			count += 1
		
		print("Item added: ", resource," ", count)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false

func _show_loot_popup(texture: Texture, from_position: Vector2, inv_item: bool) -> void:
	var popup := Sprite2D.new()
	popup.texture = texture
	if inv_item:
		popup.apply_scale(Vector2(0.15, 0.15))
	else:
		popup.apply_scale(Vector2(0.25, 0.25))
	popup.modulate.a = 1
	popup.global_position = from_position
	add_child(popup)
	var t = get_tree().create_tween()
	t.tween_property(popup, "global_position:y", popup.global_position.y - 40, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(popup, "modulate:a", 0.0, 0.5).set_delay(0.3)
	t.finished.connect(popup.queue_free)
