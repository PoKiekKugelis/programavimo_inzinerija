extends Area2D

@export var target_level : PackedScene
func _on_body_entered(body):
	if (body.name == "Player"):
		
		#Sitas laikinai neveikia, kol neturim normalaus tree hierarchy
		Events.run_won.emit()
		
