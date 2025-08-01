extends Area2D

func _on_area_2d_body_entered(body):
	if body  == "Player":  # or use `if body is Player`
		body.lock_camera_for(3.0)  # Locks camera for 1 second
		body.die()  # Handle respawn or scene reload
