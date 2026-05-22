extends Node2D

## つらら固定オブジェクト
## RESPAWN/IDLE/WARNING/FALLING(7コマ目)を担当
## FALLINGになったらIcicleFallを召喚して落下させる

enum IcicleState {
	IDLE,
	WARNING,
	FALLING,
	RESPAWN,
}

@export_group("Icicle Settings")
## 振動の幅（px）
@export var shake_amount: float = 2.0
## 振動の速さ
@export var shake_speed: float = 40.0
## 警告時間（秒）
@export var warning_duration: float = 0.8
## IcicleFall シーン
@export var icicle_fall_scene: PackedScene

var state: IcicleState = IcicleState.IDLE
var _warning_timer: float = 0.0
var _shake_timer: float = 0.0

const FRAME_W: int = 32

@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea


func _ready() -> void:
	_set_state(IcicleState.IDLE)
	SignalManager.on_stage_reset.connect(_on_stage_reset)


func _process(delta: float) -> void:
	match state:
		IcicleState.IDLE:
			pass

		IcicleState.WARNING:
			_warning_timer -= delta
			_shake_timer += delta * shake_speed
			sprite.position.x = sin(_shake_timer) * shake_amount
			if _warning_timer <= 0.0:
				_set_state(IcicleState.FALLING)

		IcicleState.FALLING, IcicleState.RESPAWN:
			pass


func _set_state(new_state: IcicleState) -> void:
	state = new_state
	match state:
		IcicleState.IDLE:
			_show_frame(5)  # 6コマ目
			sprite.position.x = 0

		IcicleState.WARNING:
			_warning_timer = warning_duration
			_shake_timer = 0.0
			# 見た目はIDLEのまま（6コマ目）振動

		IcicleState.FALLING:
			_show_frame(6)  # 7コマ目
			sprite.position.x = 0
			if icicle_fall_scene:
				var fall = icicle_fall_scene.instantiate()
				var spawn_pos = global_position
				fall.finished.connect(_on_fall_finished)
				get_parent().add_child(fall)
				fall.global_position = spawn_pos

		IcicleState.RESPAWN:
			_play_respawn()


func _show_frame(frame_index: int) -> void:
	sprite.region_enabled = true
	sprite.region_rect = Rect2(frame_index * FRAME_W, 0, FRAME_W, 48)


func _play_respawn() -> void:
	# 1〜5コマ目をタイマーで順番に再生
	_show_frame(0)
	var fps: float = 8.0
	for i in range(1, 5):
		await get_tree().create_timer(1.0 / fps).timeout
		_show_frame(i)
	await get_tree().create_timer(1.0 / fps).timeout
	_set_state(IcicleState.IDLE)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state == IcicleState.IDLE:
		_set_state(IcicleState.WARNING)


func _on_fall_finished() -> void:
	# IcicleFall の落下・破壊が終わったらRESPAWNへ
	_set_state(IcicleState.RESPAWN)


func _on_stage_reset() -> void:
	_set_state(IcicleState.IDLE)
