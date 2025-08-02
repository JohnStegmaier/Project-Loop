extends CharacterBody2D

@export var Jump_Buffer_Time: float
@export var Coyote_Time: float
@export var BlasterShot: PackedScene

const MOVE_SPEED = 155
const JUMP_FORCE = 700
const MAX_SPEED = 2000
const MAX_FALL_SPEED = 700

const DEBUG_OBJECT = false
const SLIDE_SPEED = 500
const SLIDE_DURATION = 0.17
const EXTENDED_COYOTE_TIME = 0.4
const VARIABLE_JUMP_TIME = 2
const JUMP_CUT_MULTIPLIER = 100

var is_sliding: bool = false
var slide_timer: float = 0.0
var timer : SceneTreeTimer

var sprite : AnimatedSprite2D

var GRAVITY = 30
var FRICTION_GROUND = 0.5
var FRICTION_AIR = 0.6
var FRICTION_AIR_X = FRICTION_AIR
var GRAVITY_X = GRAVITY
		
var direction_vector : float
var direction_vector_buffer : float
var jump_available : bool
var jump_buffer : bool

var is_crouching: bool = false

# Dash variables
const DASH_SPEED = 1400
const DASH_DURATION = 0.08
const DASH_COOLDOWN = 0.5

var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var is_dashing: bool = false
var dash_direction: int = 0

var is_hovering: bool = false
var hover_timer: float = 0.0
const HOVER_DURATION = 0.1

var coyote_timer_started: bool = false
var coyote_jump_active: bool = false
var gravity_disabled: bool = false

#gun_stuff
var is_charging: bool = false
var charge_time: float = 0.0
const MAX_CHARGE_TIME: float = 1.5
const FIRE_RATE_MIN: float = 0.1
const FIRE_RATE_MAX: float = 0.35
var fire_cooldown: float = 0.0
var projectile_count = 0


func _ready() -> void:
	timer = get_tree().create_timer(0)
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	sprite = get_node("Cyborg")
	Jump_Buffer_Time = 0.1
	Coyote_Time = 0.1
	jump_buffer = false
	direction_vector = 0
	direction_vector_buffer = 0

func _on_spawn(position: Vector2, direction: String):
	var camera : Camera2D = get_node("Camera2D") # Adjust path if your camera has a different name

	if camera:
		camera.position_smoothing_enabled = false

	global_position = position

	# Re-enable smoothing after one frame
	if camera:
		await get_tree().process_frame
		camera.position_smoothing_enabled = true
	# do something with direction here

######################################################## Physics Processing Loop ########################################################
func _physics_process(delta: float) -> void:
	Logger.log_debug("Time left on timer: %s" % timer.time_left)
	if fire_cooldown > 0:
		fire_cooldown -= delta
	#Start charging
	if Input.is_action_just_pressed("blaster"):
		is_charging = true
		charge_time = 0.0
#
	# Hold to charge
	if is_charging and Input.is_action_pressed("blaster"):
		charge_time += delta
		charge_time = min(charge_time, MAX_CHARGE_TIME)
#
	## Release to fire
	if is_charging and Input.is_action_just_released("blaster") and fire_cooldown <= 0:
		is_charging = false
		if charge_time >= 0.5:
				fire_projectile(charge_time / MAX_CHARGE_TIME)
	
	if Input.is_action_just_pressed("blaster") and fire_cooldown <= 0:
		projectile_count = get_active_projectile_count()
		if projectile_count < 3:
			fire_cooldown = FIRE_RATE_MIN  # shorter cooldown if less than 3 projectiles
		else:
			fire_cooldown = FIRE_RATE_MAX  # normal cooldown (0.5)
		fire_projectile(0.5)
		print("Active projectiles:", get_active_projectile_count())


	if is_crouching:
		direction_vector = 0
	else:
		direction_vector = direction_based_on_input()
		debug_log_movement()
		apply_gravity_to_player()
		clamp_player_velocity()
	
	# Dash input check
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		if direction_vector != 0:
			is_dashing = true
			dash_timer = DASH_DURATION
			dash_cooldown_timer = DASH_COOLDOWN
			dash_direction = sign(direction_vector)
			velocity = Vector2(dash_direction * DASH_SPEED, 0)
			velocity.y = 0  # Optional: cancel vertical movement during dash

	# Dash active
	if is_dashing:
		dash_timer -= delta
		FRICTION_AIR = 0.8
		GRAVITY = 0
		velocity = Vector2(dash_direction * DASH_SPEED, 0)
		if dash_timer <= 0:
			is_dashing = false
			FRICTION_AIR = FRICTION_AIR_X
			GRAVITY = GRAVITY_X
			is_hovering = true
			hover_timer = HOVER_DURATION
			
	if is_hovering:
		hover_timer -= delta
		velocity.x = direction_based_on_input()
		velocity.y = 0  # Freeze motion (no falling or drifting)
	if hover_timer <= 0:
		is_hovering = false

# Slide input (can only start slide if on floor and not sliding already)
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding and not is_dashing and not is_hovering:
		
		is_sliding = true
		slide_timer = SLIDE_DURATION
		velocity.x = sign(direction_vector) * SLIDE_SPEED

	if is_sliding:
		slide_timer -= delta
		velocity.x = sign(velocity.x) * SLIDE_SPEED  # Keep constant speed during slide
		if slide_timer <= 0:
			#FRICTION_GROUND = 0.5
			set_player_velocity_with_ground_friction()
			is_sliding = false


	if is_on_floor():
		if Input.is_action_pressed("crouch"):
			is_crouching = true
		else:
			is_crouching = false
		if is_crouching:
			if sprite:
				sprite.play("crouch")
		elif abs(velocity.x) > 5:
			if sprite:
				sprite.flip_h = velocity.x < 0
				sprite.play("run")
		else:
			if sprite:
				sprite.play("idle")
			is_crouching = false
		set_player_velocity_with_ground_friction()
		jump_available = true
		direction_vector_buffer = direction_vector
		if(jump_buffer):
			jump_buffer = false
			jump_available = false
			jump()
			
	if not is_on_floor():
		if sprite and abs(velocity.x) > 100:
			sprite.flip_h = velocity.x < 0  # Flip based on midair direction
			if sprite.animation != "jumping":
				sprite.play("jumping")  # Ensure jumping animation stays on
		if jump_available == true:
			var grace_time = Coyote_Time
			if is_sliding:
				grace_time = EXTENDED_COYOTE_TIME
			get_tree().create_timer(grace_time).timeout.connect(_on_coyote_timer_timeout)
			velocity.y = 0
		if(direction_vector == direction_vector_buffer):
			set_player_velocity_with_ground_friction()
		else:	
			direction_vector_buffer = 0
			set_player_velocity_with_air_friction()
			
	# Update dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if Input.is_action_just_pressed("jump"):
		if is_sliding:
			is_sliding = false
			jump_available = false
			jump()
		elif is_crouching:
			jump_available = false
			is_crouching = false
			jump()
		elif jump_available:
			jump_available = false
			jump()	
		else:
			jump_buffer = true
			get_tree().create_timer(Jump_Buffer_Time).timeout.connect(on_jump_buffer_timeout)
	move_and_slide()
######################################################## Physics Processing Loop ######################################################## 
	

func _input(event: InputEvent) -> void:
	if(event.is_action_released("jump")):
		cut_jump_short()
	
func direction_based_on_input() -> float :
	return (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * MOVE_SPEED

func apply_gravity_to_player() -> void:
	velocity.y += GRAVITY

func clamp_player_velocity() -> void:
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_FALL_SPEED)
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

func set_player_velocity_with_ground_friction() -> void:
	velocity.x *= FRICTION_GROUND
	velocity.x += direction_vector

func set_player_velocity_with_air_friction() -> void:
	velocity.x += direction_vector
	velocity.x *= FRICTION_AIR

func debug_log_movement() -> void :
	if DEBUG_OBJECT:
		Logger.log_debug("direction_vector: %s" % [direction_vector])
		Logger.log_debug("Input.get_action_strength(\"move_right\"): %s" % [Input.get_action_strength("move_right")])
		Logger.log_debug("Input.get_action_strength(\"move_left\"): %s"	% [Input.get_action_strength("move_left")])
		Logger.log_debug("Velocity x: %s y: %s" % [velocity.x, velocity.y])
		Logger.log_debug("Hello World")

func jump() -> void:
	timer = get_tree().create_timer(2)
	if sprite:
		sprite.play("jumping")
	var actual_jump_force = JUMP_FORCE
	if is_sliding:
		actual_jump_force *= 1.8
		velocity.y = -actual_jump_force
	else:
		velocity.y = -JUMP_FORCE

func _on_coyote_timer_timeout() -> void:
	jump_available = false
	velocity.y += GRAVITY

func cut_jump_short () -> void:
	velocity.y += timer.time_left * JUMP_CUT_MULTIPLIER
	timer.time_left = 0
	
func on_jump_buffer_timeout() -> void:
	Logger.log_debug("Jump buffer has timed out")
	jump_buffer = false

func _on_death_zone_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().reload_current_scene()

func fire_projectile(charge_ratio: float) -> void:
	var projectile = BlasterShot.instantiate() as BlasterShot
	get_parent().add_child(projectile)
	projectile.global_position = global_position
	var is_facing_left = sprite.flip_h
	projectile.init(charge_ratio, is_facing_left)
	
func get_active_projectile_count() -> int:
	var count = 0
	for child in get_parent().get_children():
		if child is BlasterShot:
			count += 1
	return count
