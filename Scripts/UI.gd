extends CanvasLayer

@onready var score_label: RichTextLabel = get_node("Control/Panel/Score")

func _ready() -> void:
	ScoreManager.score_label = get_node("Control/Panel/Score")
	score_label.text = "[center] Score: [color=yellow]%d[/color][/center]" % ScoreManager.score
