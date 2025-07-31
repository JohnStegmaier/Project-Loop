extends CanvasLayer

@onready var score_label = $Control/Panel/Score
var score: int

func _ready() -> void:
	score = 0
	score_label.text = "[center] Score: [color=yellow]%d[/color][/center]" % score

func _on_bolt_collected():
	score += 1
	score_label.text = "[center] Score: [color=yellow]%d[/color][/center]" % score
