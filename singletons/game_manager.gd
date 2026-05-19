extends Node

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")
const LEVEL_SCENE: PackedScene = preload("res://scenes/level_base/level_base.tscn")

func load_main_scene():
	get_tree().change_scene_to_packed(MAIN_SCENE)

func load_level_scene():
	get_tree().change_scene_to_packed(LEVEL_SCENE)
