extends CanvasLayer

@onready var score_label = $Control/Panel/Score

func _ready() -> void:
	ScoreManager.score_label = $Control/Panel/Score
	score_label.text = "[center] Score: [color=yellow]%d[/color][/center]" % ScoreManager.score