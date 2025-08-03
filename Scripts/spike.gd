extends Node2D

func _on_body_entered(body):
	if body is CharacterBody2D and body.name == "Player":
		get_tree().reload_current_scene()
		print("battery should reduce. code this.")
