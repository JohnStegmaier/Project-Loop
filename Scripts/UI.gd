extends CanvasLayer

const DEBUG_LOG = true

@onready var score_label: RichTextLabel = get_node("Control/Panel/Score")
@onready var battery_bar: ProgressBar = get_node("Control/LifeBarPanel/Battery")

func _ready() -> void:
	ScoreManager.score_label = get_node("Control/Panel/Score")
	score_label.text = "[center] Score: [color=yellow]%d[/color][/center]" % ScoreManager.score
	battery_bar.value = ScoreManager.health
	
func _process(delta: float) -> void:
	ScoreManager.health -= 0.00001 * delta
	battery_bar.value = ScoreManager.health
	Logger.log_debug("Battery bar value: %s" % battery_bar.value, DEBUG_LOG)
	Logger.log_debug("ScoreManager.health value: %s" % ScoreManager.health, DEBUG_LOG)
