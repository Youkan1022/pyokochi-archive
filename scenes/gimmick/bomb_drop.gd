extends CharacterBody2D

## 落下爆弾ギミック（bomb_dropper 専用）
## 重力で落下し、地面に着いたら落下停止して爆発する
## 落下中にプレイヤーに触れたらTICKING開始（落下は継続）

enum BombState {
	FALLING,    # 落下中
	TICKING,    # カウントダウン中（落下継続もあり）
	EXPLODING,  # 爆発中
	DONE        # 爆発完了
}

@export_group("Bomb Settings")
## 爆発までの時間（秒）
@export var fuse_duration: float = 1.0
## 点滅の速さ（爆発直前は速くなる）
@export var blink_speed_start: float = 4.0
@export var blink_speed_end: float = 20.0

var state: BombState = BombState.FALLING
var fuse_timer: float = 0.0
var blink_timer: float = 0.0
var _fall_velocity: float = 0.0

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_shape: CollisionShape2D = $ExplosionArea/CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var ground_ray: RayCast2D = $GroundRay


func _ready() -> void:
	explosion_shape.set_deferred("disabled", true)
	animated_sprite.play("idle")
	# GroundRay がプレイヤーを検知しないよう例外追加
	var player = get_tree().get_first_node_in_group("player")
	if player:
		ground_ray.add_exception(player)
	SignalManager.on_stage_reset.connect(_on_stage_reset)


func _physics_process(delta: float) -> void:
	match state:
		BombState.FALLING, BombState.TICKING:
			# RayCast2D で地面を検知（プレイヤーとは物理影響なし）
			if not ground_ray.is_colliding():
				_fall_velocity += GRAVITY * delta
				position.y += _fall_velocity * delta
			else:
				_fall_velocity = 0.0
				if state == BombState.FALLING:
					_activate()
			if state == BombState.TICKING:
				_process_ticking(delta)

		BombState.EXPLODING, BombState.DONE:
			pass


func _process_ticking(delta: float) -> void:
	fuse_timer -= delta

	var progress: float = clamp(1.0 - fuse_timer / fuse_duration, 0.0, 1.0)
	var blink_speed: float = lerp(blink_speed_start, blink_speed_end, progress)
	blink_timer += delta * blink_speed
	animated_sprite.modulate.a = 1.0 if fmod(blink_timer, 1.0) < 0.5 else 0.3

	if fuse_timer <= 0.0:
		_explode()


func _activate() -> void:
	# 地面着地時に呼ばれる
	if state == BombState.TICKING:
		return
	if state != BombState.FALLING:
		return
	state = BombState.TICKING
	fuse_timer = fuse_duration
	animated_sprite.play("ticking")
	AudioManager.play("bomb_ticking")


func _explode() -> void:
	state = BombState.EXPLODING
	animated_sprite.modulate.a = 1.0
	AudioManager.stop("bomb_ticking")
	explosion_shape.disabled = false

	if AudioManager.SOUNDS.has("explosion"):
		AudioManager.play("explosion")

	animated_sprite.play("explode")
	await animated_sprite.animation_finished

	state = BombState.DONE
	explosion_shape.disabled = true
	queue_free()


func _on_detection_area_body_entered(body: Node2D) -> void:
	# プレイヤーが触れたらTICKING開始（落下は継続）
	if body.is_in_group("player") and state == BombState.FALLING:
		state = BombState.TICKING
		fuse_timer = fuse_duration
		animated_sprite.play("ticking")
		AudioManager.play("bomb_ticking")


func _on_stage_reset() -> void:
	state = BombState.DONE
	set_physics_process(false)
	queue_free()
