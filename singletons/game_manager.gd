extends Node

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const LEVELS: Array = [
	"res://scenes/level_base/level_1.tscn",
	"res://scenes/level_base/level_2.tscn",
	"res://scenes/level_base/level_3.tscn",
	"res://scenes/level_base/level_4.tscn",
]
const END_SCENE: String = "res://scenes/main/main.tscn"

var current_level_index: int = 0

func load_main_scene() -> void:
	WindManager.disable_wind()
	current_level_index = 0
	get_tree().change_scene_to_packed(MAIN_SCENE)

func load_level_scene() -> void:
	get_tree().change_scene_to_file(LEVELS[current_level_index])

func load_next_level() -> void:
	WindManager.disable_wind()  # レベル遷移時に風を確実に止める
	current_level_index += 1
	if current_level_index >= LEVELS.size():
		get_tree().change_scene_to_file(END_SCENE)
	else:
		get_tree().change_scene_to_file(LEVELS[current_level_index])
