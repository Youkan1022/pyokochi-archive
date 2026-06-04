extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	AudioManager.play_bgm("main")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		GameManager.load_level_scene()
