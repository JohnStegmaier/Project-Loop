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
	direction_vector = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * MOVE_SPEED
	# Logger.log_debug("direction_vector: %s" % [direction_vector])
	# Logger.log_debug("Input.get_action_strength(\"move_right\"): %s" % [Input.get_action_strength("move_right")])
	# Logger.log_debug("Input.get_action_strength(\"move_left\"): %s"	% [Input.get_action_strength("move_left")])

	# Add Gravity to player
	velocity.y += GRAVITY
	
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)

	if is_on_floor():
		velocity.x *= FRICTION_GROUND
		velocity.x += direction_vector
		jump_available = true
		direction_vector_buffer = direction_vector
		# coyote_timer.stop()
		if(jump_buffer):
			jump_buffer = false
			jump_available = false
			jump()
	if not is_on_floor():
		if jump_available == true:
			get_tree().create_timer(Coyote_Time).timeout.connect(_on_coyote_timer_timeout)
		if(direction_vector == direction_vector_buffer):
			velocity.x *= FRICTION_GROUND
			velocity.x += direction_vector
		else:	
			direction_vector_buffer = 0
			velocity.x += direction_vector/1.5
			velocity.x *= FRICTION_AIR

	if Input.is_action_just_pressed("jump"):
		if jump_available:
			jump_available = false
			jump()	
		else:
			jump_buffer = true
			Logger.log_debug("Setting jump buffer to true")		
			get_tree().create_timer(Jump_Buffer_Time).timeout.connect(on_jump_buffer_timeout)
	# Logger.log_debug("Velocity x: %s y: %s" % [velocity.x, velocity.y])
	move_and_slide()


func jump() -> void:
	velocity.y = -JUMP_FORCE

func _on_coyote_timer_timeout() -> void:
	jump_available = false

func on_jump_buffer_timeout() -> void:
	Logger.log_debug("Jump buffer has timed out")
	jump_buffer = false
