extends Control



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game Scenes/01_loop_start.tscn")
	pass # Replace with function body.

func _on_gabe_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game Scenes/LevelTest.tscn")
	pass # Replace with function body.


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game Scenes/00_options_menu.tscn")
	pass # Replace with function body.


func _on_quit_game_pressed() -> void: # Quit the game
	get_tree().quit()
	pass # Replace with function body.
