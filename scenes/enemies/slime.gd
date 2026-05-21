extends CharacterBody2D

## スライム敵
## 左右にパトロールし、プレイヤーに触れるとHit判定
## 矢が当たるとダウンして消滅する

enum SlimeState {
	WALK,  # 歩き（パトロール）
	DOWN,  # ダウン（死亡）
}

@export_group("Slime Settings")
## 移動速度
@export var speed: float = 40.0
## 折り返しまでの距離（片道）
@export var patrol_distance: float = 48.0
## 地面からのオフセット（大きいほど浮く、小さいほど沈む）
@export var ground_offset: float = 8.0

var state: SlimeState = SlimeState.WALK
var _direction: float = 1.0
var _traveled: float = 0.0
var _origin: Vector2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var damage_area_shape: CollisionShape2D = $DamageArea/CollisionShape2D
@onready var ray: RayCast2D = $RayCast2D

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	_origin = global_position
	sprite.flip_h = _direction > 0  # 初期向きを方向に合わせる
	sprite.play("walk")
	SignalManager.on_stage_reset.connect(_on_stage_reset)


func _physics_process(delta: float) -> void:
	if state == SlimeState.DOWN:
		return

	# RayCast2D で地面を検知して重力を適用
	if not ray.is_colliding():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
		# 足元のY = レイの起点Y(ノードのposition.y + offset -4) + target長さ(16) の分だけ上に払い出す
		global_position.y = ray.get_collision_point().y - ground_offset

	# パトロール移動
	velocity.x = speed * _direction
	_traveled += speed * delta

	# 折り返し
	if _traveled >= patrol_distance:
		_traveled = 0.0
		_direction *= -1.0
		sprite.flip_h = _direction > 0

	global_position += velocity * delta


func take_hit() -> void:
	if state == SlimeState.DOWN:
		return
	state = SlimeState.DOWN
	velocity = Vector2.ZERO
	collision.set_deferred("disabled", true)
	damage_area_shape.set_deferred("disabled", true)
	sprite.play("down")
	await sprite.animation_finished
	queue_free()


func _on_stage_reset() -> void:
	queue_free()
