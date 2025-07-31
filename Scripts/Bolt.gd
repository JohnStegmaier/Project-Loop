extends Area2D

func _ready():
    connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
    if body.name == "Player":
        print("U GOT A BOLT WOOOOOOOO!")
        ScoreManager.add_score(1)
        queue_free()
