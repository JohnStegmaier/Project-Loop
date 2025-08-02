extends Area2D

@export var hit_damage : float = 20
@export var health : float = 100
const DEBUG_LOG = true;

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	pass # Replace with function body.

func take_hit(damage_scale : float = 1):
	health -= hit_damage * damage_scale
	Logger.log_debug("%s object took a hit dealing (%s×%s) damage. Remainnig health %s" % [self.name, hit_damage, damage_scale, health], DEBUG_LOG)
	check_for_destruction()

func check_for_destruction() -> void:
	if health <=0:
		queue_free()	