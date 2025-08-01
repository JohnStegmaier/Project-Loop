extends CharacterBody2D

@export var Jump_Buffer_Time: float
@export var Coyote_Time: float

const MOVE_SPEED = 155
const JUMP_FORCE = 700
const MAX_SPEED = 2000
const FRICTION_GROUND = 0.5
const DEBUG_OBJECT = false

var GRAVITY = 30
var FRICTION_AIR = 0.6
var FRICTION_AIR_X = FRICTION_AIR
var GRAVITY_X = GRAVITY
		
var direction_vector : float
var direction_vector_buffer : float
var jump_available : bool
var jump_buffer : bool


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


func _ready() -> void:
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	Jump_Buffer_Time = 0.1
	Coyote_Time = 0.1
	jump_buffer = false
	direction_vector = 0
	direction_vector_buffer = 0


func _on_spawn(position: Vector2, direction: String):
	global_position = position
	# do something with direction here

func _physics_process(delta: float) -> void:
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


	if is_on_floor():
		set_player_velocity_with_ground_friction()
		jump_available = true
		direction_vector_buffer = direction_vector
		if(jump_buffer):
			jump_buffer = false
			jump_available = false
			jump()
	if not is_on_floor():
		if jump_available == true:
			get_tree().create_timer(Coyote_Time).timeout.connect(_on_coyote_timer_timeout)
		if(direction_vector == direction_vector_buffer):
			set_player_velocity_with_ground_friction()
		else:	
			direction_vector_buffer = 0
			set_player_velocity_with_air_friction()
			
	# Update dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if Input.is_action_just_pressed("jump"):
		if jump_available:
			jump_available = false
			jump()	
		else:
			jump_buffer = true
			get_tree().create_timer(Jump_Buffer_Time).timeout.connect(on_jump_buffer_timeout)
	move_and_slide()

func direction_based_on_input() -> float :
	return (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * MOVE_SPEED

func apply_gravity_to_player() -> void:
	velocity.y += GRAVITY

func clamp_player_velocity() -> void:
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	#velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

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

func jump() -> void:
	velocity.y = -JUMP_FORCE

func _on_coyote_timer_timeout() -> void:
	jump_available = false

func on_jump_buffer_timeout() -> void:
	Logger.log_debug("Jump buffer has timed out")
	jump_buffer = false
