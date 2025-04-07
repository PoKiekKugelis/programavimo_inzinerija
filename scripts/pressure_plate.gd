extends Node2D

# animation player reference for pressure plate visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer as AnimationPlayer

# path to the linked boulder in the scene
@export var boulder_path: NodePath  

# reference to the actual boulder instance
var boulder: Boulder = null

func _ready() -> void:
	# connect the pressure plate's trigger area
	$Area2D.connect("body_entered", Callable(self, "_on_area_2d_body_entered"))
	
	# get the boulder reference if path is specified
	if boulder_path:
		boulder = get_node(boulder_path)

# triggered when a body enters the pressure plate area
func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	animation_player.play("Disable")  # play depress animation
	
	# only activate if player stepped on it and boulder exists
	if body is Player and boulder != null:
		boulder.activate()  # make the boulder fall

# triggered when body leaves the pressure plate area
func _on_area_2d_body_exited(body: Node2D) -> void:
	animation_player.play("Enable")  # play reset animation
	# boulder remains active after leaving
