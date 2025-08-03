extends Area2D

const DEBUG_LOGS = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		$BoltGet.play()
		hide()
		$CollisionShape2D.disabled = true
		Logger.log_debug("U GOT A BOLT WOOOOOOOO!", DEBUG_LOGS)
		ScoreManager.add_score(1) 
		await get_tree().create_timer($BoltGet.stream.get_length()).timeout
		queue_free()
