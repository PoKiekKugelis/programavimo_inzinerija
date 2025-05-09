extends HBoxContainer
class_name IntentUI

@onready var sprite: TextureRect = $Sprite
@onready var number: Label = $Number

func update_intent(intent: Intent) -> void:
	if not intent:
		hide()
		return
	sprite.texture = intent.sprite
	sprite.visible = sprite.texture != null
	number.text = str(intent.number)
	number.visible = intent.number.length() > 0
	show()
