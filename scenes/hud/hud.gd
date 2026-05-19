extends Control

@onready var background: ColorRect = $Background

func _ready() -> void:
	#常時プロセスを有効化
	set_process_mode(Node2D.PROCESS_MODE_ALWAYS)
	hide_hud() #HUDを初期状態で非表示にする
	SignalManager.on_game_complete.connect(on_game_complete) #ゲーム完了時のシグナルに接続

func _process(delta: float) -> void:
	#ゴール後、スペースキーでメニューに戻る
	if background.visible:
		if Input.is_action_just_pressed("jump"):
			GameManager.load_main_scene()

# HUDを非表示
func hide_hud():
	background.visible = false

# HUDを表示
func show_hud():
	get_tree().paused = true # ゲームを一時停止
	background.visible = true

func on_game_complete():
	show_hud()
	
