extends Node

# AudioManager - サウンドをシングルトンで一元管理する
#
# 使い方:
#   AudioManager.play("jump")
#   AudioManager.play_bgm("level_1")

# 各SEのファイルパス
var SOUNDS = {
	"jump":           {"path": "res://assets/SoundEffect/phaseJump2.ogg", "volume_db": -15.0},
	"wall_jump":      {"path": "res://assets/SoundEffect/phaseJump2.ogg", "volume_db": -15.0},
	"dash":           {"path": "res://assets/SoundEffect/dush.wav", "volume_db": -15.0},
	"damage":         {"path": "res://assets/SoundEffect/damage2.wav", "volume_db": -10.0},
	"gravity_switch": {"path": "res://assets/SoundEffect/forceField_000.ogg", "volume_db": -15.0},
	"bow_charge":     {"path": "res://assets/SoundEffect/Bow_Release.wav", "volume_db": 0.0},
	"land":           {"path": "", "volume_db": 0.0},
	"goal":           {"path": "res://assets/SoundEffect/goal.wav", "volume_db": -20.0},
	"explosion":      {"path": "res://assets/SoundEffect/explosionCrunch_000.ogg", "volume_db": -20.0},
	"bomb_ticking":   {"path": "res://assets/SoundEffect/bomb_ticking.mp3", "volume_db": -10.0},
}

# BGMのファイルパス
var BGM = {
	"main":   "res://assets/BGM/Alan Catz/01 The Adventure Begins!.wav",
	"level_1": "res://assets/BGM/Alan Catz/02 Happy Exploring.wav",
	"level_2": "res://assets/BGM/Alan Catz/02 Happy Exploring.wav",
	"level_3": "res://assets/BGM/Alan Catz/03 No Other Choice.wav",
	"level_4": "res://assets/BGM/Alan Catz/08 Don't Wanna Fight Anymore.wav",
	"end":     "res://assets/BGM/Alan Catz/12 End of a Journey.wav",
}

# AudioStreamPlayer のプール（同時再生対応）
var _players: Dictionary = {}
var _bgm_player: AudioStreamPlayer

func _ready() -> void:
	for key in SOUNDS.keys():
		var player := AudioStreamPlayer.new()
		process_mode = Node.PROCESS_MODE_ALWAYS
		player.name = "SE_" + key
		player.volume_db = SOUNDS[key]["volume_db"]
		add_child(player)
		_load_stream(player, key)
		_players[key] = player
	# BGM専用プレイヤー
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGM"
	_bgm_player.volume_db = -25.0
	_bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_bgm_player)

func _load_stream(player: AudioStreamPlayer, key: String) -> void:
	var path: String = SOUNDS[key].get("path", "")
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

func stop(key: String) -> void:
	if not _players.has(key):
		return
	_players[key].stop()

func play_bgm(key: String) -> void:
	if not BGM.has(key):
		push_warning("AudioManager: 未登録のBGMキー -> " + key)
		return
	var path: String = BGM[key]
	if not ResourceLoader.exists(path):
		push_warning("AudioManager: BGMファイルが見つかりません -> " + path)
		return
	var stream = load(path)
	if _bgm_player.stream == stream and _bgm_player.playing:
		return  # 同じBGMが再生中なら何もしない
	_bgm_player.stream = stream
	_bgm_player.play()

func stop_bgm() -> void:
	_bgm_player.stop()

func set_bgm_volume(volume_db: float) -> void:
	_bgm_player.volume_db = volume_db

# SEファイルを動的に差し替える
func set_sound(key: String, path: String) -> void:
	if not _players.has(key):
		push_warning("AudioManager: 未登録のSEキー -> " + key)
		return
	SOUNDS[key] = path
	_load_stream(_players[key], key)
