extends CanvasLayer

@onready var level_root: Node2D = get_node("../")

func _on_resume_pressed():
	if(level_root.has_method("pauseMenu")):
		level_root.pauseMenu()
	else:
		Logger.log_error("Root node of scene doesn't have a script with pausing functionality. Please see 00_loop_start.tscn & associated script for reference")
	pass
	
func _on_quit_pressed():
	ScoreManager.health = 100
	ScoreManager.score = 0
	NavigationManager.spawn_door_tag = null
	level_root.pauseMenu()
	get_tree().change_scene_to_file("res://Scenes/Game Scenes/00_main_menu.tscn")
	pass
