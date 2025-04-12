extends Camera2D

@onready var camera: Camera2D = $"."

var zoom_speed := 10.0
var zoom_margin := 0.2
var zoom_min := 2.0
var zoom_max := 10.0
var target_zoom := Vector2(1.0, 1.0)  # Start at default 1.0 zoom

func _ready() -> void:
	target_zoom = zoom

func _process(delta: float) -> void:
	# Smoothly interpolate current zoom toward target zoom
	zoom = zoom.lerp(target_zoom, clamp(zoom_speed * delta, 0, 1))
	zoom.x = clamp(zoom.x, zoom_min, zoom_max)
	zoom.y = clamp(zoom.y, zoom_min, zoom_max)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom += Vector2(0.3, 0.3)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom -= Vector2(0.3, 0.3)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			target_zoom = Vector2(2.5, 2.5)

		# Clamp target zoom immediately
		target_zoom.x = clamp(target_zoom.x, zoom_min, zoom_max)
		target_zoom.y = clamp(target_zoom.y, zoom_min, zoom_max)
