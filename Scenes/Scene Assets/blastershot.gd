extends Area2D

class_name BlasterShot

var is_facing_left: bool
var speed = 100
var direction = Vector2.RIGHT
var scale_factor: float = 1.0
var sprite : AnimatedSprite2D
var no_longer_on_screen : VisibleOnScreenNotifier2D
var explosion : GPUParticles2D
var collision_shape: CollisionShape2D

static var active_projectile_count := 0

func _ready():
	sprite = get_node("AnimatedSprite2D")
	no_longer_on_screen = get_node("VisibleOnScreenNotifier2D")
	active_projectile_count += 1
	scale = Vector2.ONE * scale_factor
	no_longer_on_screen.connect("screen_exited", self._on_screen_exited)
	connect("body_entered", Callable(self, "_on_body_entered"))
	sprite.play()
	
func _exit_tree():
	active_projectile_count -= 1

func _on_screen_exited():
	queue_free()

func init(charge_ratio: float, facing_left: bool) -> void:
	charge_ratio = clamp(charge_ratio, 0.0, 1.0)
	
	
	var boost = lerp(6, 4, charge_ratio)
	speed *= boost
	
	
	direction = Vector2.LEFT if facing_left else Vector2.RIGHT
	
	if (sprite):
		sprite.flip_h = facing_left

	var scale_x = lerp(0., 1.8, charge_ratio)
	var scale_y = lerp(0.2, 2.5, charge_ratio)
	scale = Vector2(scale_x, scale_y)
	
func _process(delta: float) -> void:
	position += direction * speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		return
	else:
		speed = 0
		set_process(false)
		if collision_shape:
			collision_shape.disabled = true
		if sprite:
			sprite.visible = false
			
		explosion = get_node("blaster_impact")
		explosion.emitting = true
		explosion.restart()
		explosion.global_position = global_position
		await get_tree().create_timer(explosion.lifetime).timeout
	queue_free()
