extends Area2D

@export var hit_damage : int = 20
@export var health : int = 100
const DEBUG_LOG = true;

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	pass # Replace with function body.

func take_hit():
	health -= hit_damage
	Logger.log_debug("%s object took a hit dealing %s damage. Remainnig health %s" % [self.name, hit_damage, health], DEBUG_LOG)
	check_for_destruction()

func check_for_destruction() -> void:
	if health <=0:
		queue_free()	