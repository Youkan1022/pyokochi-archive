extends AnimatableBody2D

## 移動足場ギミック
## Path2D に沿って移動し、プレイヤーが乗れる足場として機能する
## MoveMode.LOOP  : ルートを一方向に周回
## MoveMode.BOUNCE: ルートを往復

enum MoveMode {
	LOOP,    ## 一方向周回
	BOUNCE,  ## 往復
}

@export_group("Platform Settings")
## 移動モード（LOOP / BOUNCE）
@export var move_mode: MoveMode = MoveMode.BOUNCE
## 移動速度（px/秒）
@export var speed: float = 60.0
## 参照する Path2D ノード（インスペクターで割り当て）
@export var path: Path2D

# 内部状態
var _follow: PathFollow2D
var _direction: float = 1.0  # BOUNCE 用：+1 前進 / -1 後退
var _path_length: float = 0.0
var _start_progress: float = 0.0


func _ready() -> void:
	if path == null:
		push_error("MovingPlatform: Path2D が未設定です。インスペクターで 'path' を割り当ててください。")
		return

	_path_length = path.curve.get_baked_length()

	_follow = PathFollow2D.new()
	_follow.loop = (move_mode == MoveMode.LOOP)
	_follow.rotates = false
	path.add_child(_follow)
	_follow.progress = 0.0
	_start_progress = 0.0

	global_position = _follow.global_position

	SignalManager.on_stage_reset.connect(_on_stage_reset)


func _physics_process(delta: float) -> void:
	if _follow == null or _path_length == 0.0:
		return

	match move_mode:
		MoveMode.LOOP:
			_follow.progress += speed * delta

		MoveMode.BOUNCE:
			_follow.progress += speed * delta * _direction
			if _follow.progress >= _path_length:
				_follow.progress = _path_length
				_direction = -1.0
			elif _follow.progress <= 0.0:
				_follow.progress = 0.0
				_direction = 1.0

	# AnimatableBody2D は move_and_collide でプレイヤーを押す
	var target_pos: Vector2 = _follow.global_position
	var motion: Vector2 = target_pos - global_position
	move_and_collide(motion)


func _on_stage_reset() -> void:
	if _follow:
		_follow.progress = _start_progress
		_direction = 1.0
		global_position = _follow.global_position
