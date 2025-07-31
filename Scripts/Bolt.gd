extends Area2D

signal bolt_collected

func _ready():
    connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
    if body.name == "Player":
        print("U GOT A BOLT WOOOOOOOO!")
        bolt_collected.emit()
        queue_free()
