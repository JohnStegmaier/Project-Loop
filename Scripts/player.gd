extends CharacterBody2D

@export var Jump_Buffer_Time: float
@export var Coyote_Time: float

# @onready var coyote_timer: Timer = get_tree().create_timer(Coyote_Time)

const MOVE_SPEED = 110
const JUMP_FORCE = 1300
const GRAVITY = 60
const MAX_SPEED = 2000
const FRICTION_AIR = 0.85
const FRICTION_GROUND = 0.85
const DEBUG_OBJECT = false


var direction_vector : float
var direction_vector_buffer : float
var jump_available : bool
var jump_position : float
var jump_buffer : bool


func _ready() -> void:
	Jump_Buffer_Time = 0.1
	Coyote_Time = 0.1
	jump_buffer = false
	position.x = 50
	position.y = 600
	direction_vector = 0
	direction_vector_buffer = 0


func _physics_process(delta: float) -> void:
	# Handle left/right input
	direction_vector = direction_based_on_input()
	debug_log_movement()
	apply_gravity_to_player()
	clamp_player_velocity()

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
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

func set_player_velocity_with_ground_friction() -> void:
	velocity.x *= FRICTION_GROUND
	velocity.x += direction_vector

func set_player_velocity_with_air_friction() -> void:
	velocity.x += direction_vector/1.5
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
