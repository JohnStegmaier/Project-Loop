extends Area2D
@onready var sprite : Sprite2D
@export var hit_damage : float = 20
@export var health : float = 100
const DEBUG_LOG = true;
var dmg_boost : float = 3

var is_blinking = false
var blink_duration = 0.05   # total blink time in seconds
var blink_timer = 0.0
var blink_interval = 0.05   # how fast it toggles
var blink_toggle_timer = 0.0

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	sprite = get_node("Pillar Sprite")
	
	pass # Replace with function body.

func take_hit(damage_scale : float = 1):
	start_blinking()
	if damage_scale == 1:
		health -= hit_damage * dmg_boost
		Logger.log_debug("%s object took a hit dealing (%s×%s) damage. Remainnig health %s" % [self.name, hit_damage, dmg_boost, health], DEBUG_LOG)
	else:
		health -= hit_damage * damage_scale
		Logger.log_debug("%s object took a hit dealing (%s×%s) damage. Remainnig health %s" % [self.name, hit_damage, damage_scale, health], DEBUG_LOG)
		check_for_destruction()

func check_for_destruction() -> void:
	if health <=0:
		queue_free()	
		

func _physics_process(delta: float) -> void:
	if is_blinking:
		blink_timer -= delta
		blink_toggle_timer -= delta
		
		if blink_timer <= 0:
			is_blinking = false
			sprite.modulate = Color(1,1,1)
			return
		
		if blink_toggle_timer <= 0:
			blink_toggle_timer = blink_interval
			#if sprite.modulate == Color(255,128,0):
				#sprite.modulate = Color(1,1,1)  # normal color
			#else:
			sprite.modulate = Color(0.5,0.4,0.1)  
				
func start_blinking():
	is_blinking = true
	blink_timer = blink_duration
	blink_toggle_timer = 0
	sprite.modulate = Color(255,128,0)  # start with red
