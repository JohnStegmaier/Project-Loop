extends Node

const _01_loop_start = preload("res://Scenes/Game Scenes/01_loop_start.tscn")
const _02_first_level = preload("res://Scenes/Game Scenes/02_first_level.tscn")
const _04_reverse_transition_level = preload("res://Scenes/Game Scenes/04_reverse_transition_level.tscn")
const _05_Level = preload("res://Scenes/Game Scenes/05_Level.tscn")
const _Spawn = preload("res://Scenes/Game Scenes/Spawn.tscn")
const _start_zone = preload("res://Scenes/Game Scenes/start_zone.tscn")

signal on_trigger_player_spawn

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
	var scene_to_load

	match level_tag:
		"01_loop_start":
			scene_to_load = _01_loop_start
		"02_first_level":
			scene_to_load = _02_first_level
		"04_reverse_transition_level":
			scene_to_load = _04_reverse_transition_level
		"05_Level":
			scene_to_load = _05_Level
		"Spawn":
			scene_to_load = _Spawn
		"start_zone":
			scene_to_load = _start_zone

	if scene_to_load != null:
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
