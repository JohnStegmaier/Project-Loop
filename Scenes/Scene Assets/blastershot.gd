extends Node2D

class_name BlasterShot
var is_facing_left: bool

var speed = 400
var direction = Vector2.RIGHT

static var active_projectile_count := 0

func _ready():
	active_projectile_count += 1
	$Area2D/VisibleOnScreenNotifier2D.connect("screen_exited", self._on_screen_exited)

func _exit_tree():
	active_projectile_count -= 1

func _on_screen_exited():
	queue_free()

func init(charge_ratio: float, facing_left: bool) -> void:
	var boost = lerp(1.0, 2.0, charge_ratio)
	speed *= boost
	if facing_left:
		direction = Vector2.LEFT
	else:
		direction = Vector2.RIGHT
	scale = Vector2.ONE * lerp(1.0, 1.5, charge_ratio)

func _process(delta: float) -> void:
	position += direction * speed * delta
