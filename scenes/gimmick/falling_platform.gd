extends AnimatableBody2D

## 消える足場ギミック
## プレイヤーの FootArea（足元専用のArea2D）が乗ると点滅し、消えたあと一定時間後に復活する

enum PlatformState {
	IDLE,      # 通常（乗れる）
	WARNING,   # 点滅中（消える直前）
	HIDDEN,    # 消えている（乗れない）
	RESPAWNING # 復活中（フェードイン）
}

@export_group("Platform Settings")
## 乗ってから点滅開始までの時間（秒）
@export var stand_duration: float = 1.0
## 点滅の長さ（秒）
@export var blink_duration: float = 0.8
## 消えている時間（秒）
@export var hidden_duration: float = 3.0
## 点滅の速さ
@export var blink_speed: float = 16.0

var state: PlatformState = PlatformState.IDLE
var _timer: float = 0.0
var _blink_timer: float = 0.0
var _player_on: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea


func _ready() -> void:
	SignalManager.on_stage_reset.connect(_on_stage_reset)


func _process(delta: float) -> void:
	match state:
		PlatformState.IDLE:
			pass

		PlatformState.WARNING:
			_timer -= delta
			_blink_timer += delta * blink_speed
			# 点滅：alpha を 1.0 と 0.3 で交互に
			sprite.modulate.a = 1.0 if fmod(_blink_timer, 1.0) < 0.5 else 0.3
			if _timer <= 0.0:
				_set_state(PlatformState.HIDDEN)

		PlatformState.HIDDEN:
			_timer -= delta
			if _timer <= 0.0:
				_set_state(PlatformState.RESPAWNING)

		PlatformState.RESPAWNING:
			_timer -= delta
			# フェードイン
			sprite.modulate.a = clamp(1.0 - _timer / 0.4, 0.0, 1.0)
			if _timer <= 0.0:
				_set_state(PlatformState.IDLE)


func _set_state(new_state: PlatformState) -> void:
	state = new_state
	match state:
		PlatformState.IDLE:
			sprite.modulate.a = 1.0
			collision.disabled = false
			sprite.visible = true

		PlatformState.WARNING:
			_timer = blink_duration
			_blink_timer = 0.0

		PlatformState.HIDDEN:
			sprite.modulate.a = 0.0
			collision.disabled = true
			_timer = hidden_duration

		PlatformState.RESPAWNING:
			sprite.visible = true
			sprite.modulate.a = 0.0
			collision.disabled = true
			_timer = 0.4  # フェードイン時間


func _on_body_entered(area: Area2D) -> void:
	if area.name == "FootArea" and state == PlatformState.IDLE:
		_player_on = true
		await get_tree().create_timer(stand_duration).timeout
		if state == PlatformState.IDLE:
			_set_state(PlatformState.WARNING)


func _on_body_exited(area: Area2D) -> void:
	if area.name == "FootArea":
		_player_on = false


func _on_stage_reset() -> void:
	_player_on = false
	_set_state(PlatformState.IDLE)
