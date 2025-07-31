extends Node

const _01_loop_start = preload("res://Scenes/Game Scenes/01_loop_start.tscn")
const _02_first_level = preload("res://Scenes/Game Scenes/02_first_level.tscn")

signal on_trigger_player_spawn

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
    var scene_to_load

    match level_tag:
        "01_loop_start":
            scene_to_load = _01_loop_start
        "02_first_level":
            scene_to_load = _02_first_level

    if scene_to_load != null:
        spawn_door_tag = destination_tag
        get_tree().change_scene_to_packed(scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
    on_trigger_player_spawn.emit(position, direction)