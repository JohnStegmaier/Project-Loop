extends Sprite2D

func _ready():
	add_to_group("destructible")

@onready var debris_emitter : GPUParticles2D = $DebrisEmitter

func destroy():
	debris_emitter.emitting = true
	debris_emitter.restart()
	$Sprite2D.visible = false
	$StaticBody2D.disabled = true
	debris_emitter.emitting = true
	debris_emitter.restart()
	await get_tree().create_timer(debris_emitter.lifetime).timeout
	queue_free()
