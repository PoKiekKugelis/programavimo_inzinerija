extends Control


var target_scene = "res://scenes/game.tscn" #path of main game scene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed():
	get_tree().change_scene_to_file(target_scene) #Simply changes the scene
	pass
	
func _on_quit_pressed():
	get_tree().quit() #Simply closes the game 
	pass
