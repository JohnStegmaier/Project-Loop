extends Node

const DEBUG_LOGS = false
signal bolt_collected_global

var score = 0
@onready var score_label = null  # You’ll set this from your UI

func add_score(amount := 1):
	score += amount
	Logger.log_debug("SCORE: %s" %  score, DEBUG_LOGS)
	if score_label:
		score_label.text = "[center]Score: [color=yellow]%d[/color][/center]" % score
