extends Area2D

## 丸鋸ギミック
## Path2D に沿って移動し、プレイヤーにダメージを与える
## MoveMode.LOOP  : ルートを一方向に周回
## MoveMode.BOUNCE: ルートを往復

enum MoveMode {
	LOOP,    ## 一方向周回
	BOUNCE,  ## 往復
}

@export_group("Saw Settings")
## 移動モード（LOOP / BOUNCE）
@export var move_mode: MoveMode = MoveMode.BOUNCE
## 移動速度（px/秒）
@export var speed: float = 80.0
## スプライトの回転速度（rad/秒）
@export var rotate_speed: float = 8.0
## 参照する Path2D ノード（インスペクターで割り当て）
@export var path: Path2D

# 内部状態
var _follow: PathFollow2D
var _direction: float = 1.0  # BOUNCE 用：+1 前進 / -1 後退
var _path_length: float = 0.0

## Rocky Roads の saw.png（68x68）を使用
## Sprite2D の rotation を毎フレーム加算して回転を表現
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	if path == null:
		push_warning("CircularSaw: Path2D が未設定です。インスペクターで 'path' を割り当ててください。")
		return

	_path_length = path.curve.get_baked_length()

	_follow = PathFollow2D.new()
	_follow.loop = (move_mode == MoveMode.LOOP)
	_follow.rotates = false
	path.add_child(_follow)
	_follow.progress = 0.0

	# 初期位置を同期
	global_position = _follow.global_position

	SignalManager.on_stage_reset.connect(_on_stage_reset)


func _process(delta: float) -> void:
	# スプライト回転は Path2D の有無に関わらず常に実行
	sprite.rotation += rotate_speed * delta

	if _follow == null or _path_length == 0.0:
		return

	# パス上の移動
	match move_mode:
		MoveMode.LOOP:
			_follow.progress += speed * delta

		MoveMode.BOUNCE:
			_follow.progress += speed * delta * _direction
			# 端に達したら折り返し
			if _follow.progress >= _path_length:
				_follow.progress = _path_length
				_direction = -1.0
			elif _follow.progress <= 0.0:
				_follow.progress = 0.0
				_direction = 1.0

	global_position = _follow.global_position


func _on_stage_reset() -> void:
	if _follow:
		_follow.progress = 0.0
		_direction = 1.0
		global_position = _follow.global_position
