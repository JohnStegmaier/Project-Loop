extends Node

signal bolt_collected_global

var score = 0
@onready var score_label = null  # You’ll set this from your UI

func add_score(amount := 1):
    score += amount
    print("SCORE: ", score)
    if score_label:
        score_label.text = "[center]Score: [color=yellow]%d[/color][/center]" % score
