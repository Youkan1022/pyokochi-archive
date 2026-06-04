extends Node2D

## 全レベル共通の基底スクリプト
## 共通処理（リセット、シグナル接続、インデックス同期）を担当
## レベル固有の設定は子クラスが _level_setup() / _level_reset() をオーバーライドする


func _ready() -> void:
	get_tree().paused = false
	# 単体デバッグ時にインデックスを同期
	var current_path = get_tree().current_scene.scene_file_path
	var idx = GameManager.LEVELS.find(current_path)
	if idx != -1:
		GameManager.current_level_index = idx
	SignalManager.on_player_hit.connect(_on_player_hit)
	# レベル固有のセットアップ（子クラスが実装）
	_level_setup()


func _on_player_hit() -> void:
	SignalManager.on_stage_reset.emit()
	WindManager.disable_wind()
	AudioManager.stop_bgm()
	# レベル固有のリセット処理（子クラスが必要なら実装）
	_level_reset()
	GameManager.load_level_scene()


## 子クラスがオーバーライド：レベル開始時の固有設定（風・パーティクル等）
func _level_setup() -> void:
	pass


## 子クラスがオーバーライド：リセット時の固有処理
func _level_reset() -> void:
	pass
