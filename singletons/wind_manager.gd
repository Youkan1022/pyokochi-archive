extends Node

# 風の方向定数
enum WindDirection {
	NONE,
	UP,
	LEFT,
	RIGHT,
}

# 風のパラメータ（インスペクターから設定可能）
@export var wind_direction: WindDirection = WindDirection.NONE
@export var wind_force: float = 150.0
@export var wind_force_vertical: float = 980.0
@export var blow_duration: float = 3.0
@export var interval_duration: float = 5.0
@export var wind_enabled: bool = false

# 現在の風のベクトル
var current_wind: Vector2 = Vector2.ZERO
var is_blowing: bool = false

signal on_wind_changed(wind: Vector2)
signal on_wind_coming(wind: Vector2)  # 風が吹く0.3秒前の予告

func _ready() -> void:
	if wind_enabled:
		_start_cycle()

func _start_cycle() -> void:
	while wind_enabled:
		# 待機（0.3秒前に予告シグナルを出す）
		await get_tree().create_timer(interval_duration - 0.3).timeout
		if !wind_enabled:
			break
		# 0.3秒前に予告
		on_wind_coming.emit(_get_wind_vector(wind_direction))
		await get_tree().create_timer(0.3).timeout
		if !wind_enabled:
			break
		# 実際に風を吹かせる
		_set_wind(wind_direction)
		await get_tree().create_timer(blow_duration).timeout
		if !wind_enabled:
			break
		# 風を止める
		_set_wind(WindDirection.NONE)

func _get_wind_vector(direction: WindDirection) -> Vector2:
	match direction:
		WindDirection.UP:
			return Vector2(0, -wind_force_vertical)
		WindDirection.LEFT:
			return Vector2(-wind_force, 0)
		WindDirection.RIGHT:
			return Vector2(wind_force, 0)
		_:
			return Vector2.ZERO

func _set_wind(direction: WindDirection) -> void:
	match direction:
		WindDirection.UP:
			current_wind = Vector2(0, -wind_force_vertical)
		WindDirection.LEFT:
			current_wind = Vector2(-wind_force, 0)
		WindDirection.RIGHT:
			current_wind = Vector2(wind_force, 0)
		WindDirection.NONE:
			current_wind = Vector2.ZERO
	is_blowing = current_wind != Vector2.ZERO
	on_wind_changed.emit(current_wind)

func enable_wind(direction: WindDirection) -> void:
	disable_wind()  # 先にリセットして二重起動を防ぐ
	wind_direction = direction
	wind_enabled = true
	_start_cycle()

func disable_wind() -> void:
	wind_enabled = false
	_set_wind(WindDirection.NONE)
