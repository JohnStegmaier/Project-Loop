extends Node2D

@export var player: Node2D
@export var projectile_scene: PackedScene
@export var fire_rate: float = 2.0
@export var projectile_speed: float = 100.0
@export var range: float = 500.0
var timer : Timer

func _ready():
	timer = get_node("Timer")
	timer.wait_time = fire_rate
	timer.start()

func _on_Timer_timeout():
	if player and position.distance_to(player.position) <= range:
		fire_at_player()

func fire_at_player():
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	var dir = (player.global_position - global_position).normalized()
	projectile.global_position = global_position
	projectile.direction = dir
	projectile.speed = projectile_speed
