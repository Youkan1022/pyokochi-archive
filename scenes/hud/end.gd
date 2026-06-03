extends Control

@onready var background: ColorRect = $Background

func _ready() -> void:
	set_process_mode(Node2D.PROCESS_MODE_ALWAYS)
	hide_hud()
	SignalManager.on_game_complete.connect(on_game_complete)

func _process(delta: float) -> void:
	if background.visible:
		if Input.is_action_just_pressed("jump"):
			get_tree().paused = false
			GameManager.load_next_level()
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().paused = false
			GameManager.load_main_scene()

func hide_hud() -> void:
	background.visible = false

func show_hud() -> void:
	get_tree().paused = true
	background.visible = true

func on_game_complete() -> void:
	show_hud()
	
