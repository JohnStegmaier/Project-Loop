extends Area2D

const DEBUG_LOGS = false

func _ready():
    connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
    if body.name == "Player":
        Logger.log_debug("U GOT A BOLT WOOOOOOOO!", DEBUG_LOGS)
        ScoreManager.add_score(1)
        queue_free()
