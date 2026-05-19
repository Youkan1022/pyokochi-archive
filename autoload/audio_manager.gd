extends Node

# AudioManager - サウンドをシングルトンで一元管理する
#
# 使い方:
#   AudioManager.play("jump")
#   AudioManager.play("dash")

# 各SEのファイルパス
var SOUNDS = {
	"jump":           {"path": "res://assets/SoundEffect/phaseJump2.ogg", "volume_db": -15.0},
	"wall_jump":      {"path": "res://assets/SoundEffect/phaseJump2.ogg", "volume_db": -15.0},
	"dash":           {"path": "res://assets/SoundEffect/dush.wav", "volume_db": -15.0},
	"damage":         {"path": "res://assets/SoundEffect/damage2.wav", "volume_db": -10.0},
	"gravity_switch": {"path": "res://assets/SoundEffect/forceField_000.ogg", "volume_db": -15.0},
	"bow_charge":     {"path": "res://assets/SoundEffect/Bow_Release.wav", "volume_db": 0.0},
	"land":           {"path": "", "volume_db": 0.0},  # TODO: ファイルを追加したら設定
	"goal":           {"path": "res://assets/SoundEffect/goal.wav", "volume_db": -20.0},
}

# AudioStreamPlayer のプール（同時再生対応）
var _players: Dictionary = {}

func _ready() -> void:
	for key in SOUNDS.keys():
		var player := AudioStreamPlayer.new()
		process_mode = Node.PROCESS_MODE_ALWAYS
		player.name = "SE_" + key
		player.volume_db = SOUNDS[key]["volume_db"]  # ← 追加
		add_child(player)
		_load_stream(player, key)
		_players[key] = player

func _load_stream(player: AudioStreamPlayer, key: String) -> void:
	var path: String = SOUNDS[key].get("path", "")  # ← pathキーに変更
	if path == "":
		return
	if ResourceLoader.exists(path):
		player.stream = load(path)
	else:
		push_warning("AudioManager: ファイルが見つかりません -> " + path)

func play(key: String) -> void:
	if not _players.has(key):
		push_warning("AudioManager: 未登録のSEキー -> " + key)
		return
	var player: AudioStreamPlayer = _players[key]
	if player.stream == null:
		return
	player.play()

# SEファイルを動的に差し替える（新しいファイルを追加した際に使用）
func set_sound(key: String, path: String) -> void:
	if not _players.has(key):
		push_warning("AudioManager: 未登録のSEキー -> " + key)
		return
	SOUNDS[key] = path
	_load_stream(_players[key], key)
