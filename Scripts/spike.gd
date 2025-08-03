extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body is CharacterBody2D and body.name == "Player":
		body.apply_knockback(global_position)
		print("battery should reduce. code this.")
