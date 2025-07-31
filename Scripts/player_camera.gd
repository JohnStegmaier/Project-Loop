extends Camera2D

const DEBUG_MODE = true
const BOARDER_ZONE = 50
const PAN_SPEED = 1
const RETRACT_SPEED = 3

func _physics_process(delta: float) -> void:
	if Input.get_action_strength("move_right") > 0:
		if self.position.x < BOARDER_ZONE:
			self.position.x += PAN_SPEED
		pass
	elif Input.get_action_strength("move_left") > 0:
		if self.position.x > -BOARDER_ZONE:
			self.position.x -= PAN_SPEED
		pass
	else: restore_camera_to_zero()   

func restore_camera_to_zero() -> void:
	if self.position.x > 0:
		Logger.log_debug("Restoring position from right", DEBUG_MODE)
		self.position.x -= RETRACT_SPEED
	if self.position.x < 0:
		Logger.log_debug("Restoring position from left", DEBUG_MODE)
		self.position.x += RETRACT_SPEED
