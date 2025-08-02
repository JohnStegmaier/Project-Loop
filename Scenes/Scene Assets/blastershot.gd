extends Node2D

class_name BlasterShot

var is_facing_left: bool
var speed = 100
var direction = Vector2.RIGHT
var scale_factor: float = 1.0

static var active_projectile_count := 0

func _ready():
	active_projectile_count += 1
	scale = Vector2.ONE * scale_factor
	$Area2D/VisibleOnScreenNotifier2D.connect("screen_exited", self._on_screen_exited)
	$Area2D/AnimatedSprite2D.play()
	
func _exit_tree():
	active_projectile_count -= 1

func _on_screen_exited():
	queue_free()

func init(charge_ratio: float, facing_left: bool) -> void:
	charge_ratio = clamp(charge_ratio, 0.0, 1.0)
	
	
	var boost = lerp(6, 4, charge_ratio)
	speed *= boost
	
	
	direction = Vector2.LEFT if facing_left else Vector2.RIGHT
	
	if has_node("Area2D/AnimatedSprite2D"):
		$Area2D/AnimatedSprite2D.flip_h = facing_left

	var scale_x = lerp(0., 1.8, charge_ratio)
	var scale_y = lerp(0.2, 2.5, charge_ratio)
	scale = Vector2(scale_x, scale_y)
	
func _process(delta: float) -> void:
	position += direction * speed * delta
