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
var _charge_ratio
var Destructable_Object : Area2D

static var active_projectile_count := 0

func _ready():
	sprite = get_node("AnimatedSprite2D")
	no_longer_on_screen = get_node("VisibleOnScreenNotifier2D")
	collision_shape = get_node("CollisionShape2D")
	active_projectile_count += 1
	scale = Vector2.ONE * scale_factor
	no_longer_on_screen.connect("screen_exited", self._on_screen_exited)
	connect("body_entered", Callable(self, "_on_body_entered"))
	sprite.play()
	explosion = get_node("blaster_impact")
	
func _exit_tree():
	active_projectile_count -= 1

func _on_screen_exited():
	queue_free()

func init(charge_ratio: float, facing_left: bool) -> void:
	is_facing_left = facing_left
	charge_ratio = clamp(charge_ratio, 0.0, 1.0)
	_charge_ratio = charge_ratio
	var boost = lerp(6, 4, charge_ratio)
	speed *= boost
	direction = Vector2.LEFT if facing_left else Vector2.RIGHT
	if explosion:
		explosion.scale.x = -1.0 if facing_left else 1.0
	
	if (sprite):
		sprite.flip_h = facing_left

	var scale_x = lerp(0.2, 1.8, charge_ratio)
	var scale_y = lerp(0.05, 2.5, charge_ratio)
	scale = Vector2(scale_x, scale_y)
		
func _process(delta: float) -> void:
	position += direction * speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		return
		
	else:
		if(body.get_parent().get_parent().is_class("Area2D")
		&& body.get_parent().get_parent().has_method("take_hit")):
			Destructable_Object = body.get_parent().get_parent()
			Destructable_Object.take_hit()
		speed = 0
		set_process(false)
		if collision_shape:
			collision_shape.disabled = true
		if sprite:
			sprite.visible = false
			explosion.emitting = true
			explosion.restart()
			if is_facing_left == false:
				explosion.global_position = global_position + Vector2(lerp(-10,25,_charge_ratio), 0)
			else:
				explosion.global_position = global_position + Vector2(lerp(10,-5,_charge_ratio), 0)
			await get_tree().create_timer(explosion.lifetime).timeout
	queue_free()
