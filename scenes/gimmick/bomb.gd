extends Area2D

## 爆弾ギミック
## プレイヤーが近づくと起動し、カウントダウン後に爆発してプレイヤーにダメージを与える

# 状態
enum BombState {
	IDLE,       # 待機中（未起動）
	TICKING,    # カウントダウン中
	EXPLODING,  # 爆発中
	DONE        # 爆発完了
}

@export_group("Bomb Settings")
## 爆発までの時間（秒）
@export var fuse_duration: float = 1.5
## 点滅の速さ（爆発直前は速くなる）
@export var blink_speed_start: float = 4.0
@export var blink_speed_end: float = 20.0

var state: BombState = BombState.IDLE
var fuse_timer: float = 0.0
var blink_timer: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var explosion_shape: CollisionShape2D = $ExplosionArea/CollisionShape2D


func _ready() -> void:
	explosion_shape.disabled = true
	animated_sprite.play("idle")
	SignalManager.on_stage_reset.connect(_on_stage_reset)


func _process(delta: float) -> void:
	match state:
		BombState.TICKING:
			_process_ticking(delta)
		BombState.IDLE, BombState.EXPLODING, BombState.DONE:
			pass


func _process_ticking(delta: float) -> void:
	fuse_timer -= delta

	# 爆発直前に点滅スピードを上げる
	var progress: float = clamp(1.0 - fuse_timer / fuse_duration, 0.0, 1.0)
	var blink_speed: float = lerp(blink_speed_start, blink_speed_end, progress)
	blink_timer += delta * blink_speed
	animated_sprite.modulate.a = 1.0 if fmod(blink_timer, 1.0) < 0.5 else 0.3

	if fuse_timer <= 0.0:
		_explode()


func _activate() -> void:
	if state != BombState.IDLE:
		return
	state = BombState.TICKING
	fuse_timer = fuse_duration
	animated_sprite.play("ticking")
	AudioManager.play("bomb_ticking")


func _explode() -> void:
	state = BombState.EXPLODING
	animated_sprite.modulate.a = 1.0
	AudioManager.stop("bomb_ticking")

	# 爆発判定を有効化（trapLayerとしてプレイヤーHitBoxと衝突する）
	explosion_shape.disabled = false

	if AudioManager.SOUNDS.has("explosion"):
		AudioManager.play("explosion")

	animated_sprite.play("explode")
	await animated_sprite.animation_finished

	state = BombState.DONE
	explosion_shape.disabled = true
	queue_free()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_activate()


func _on_stage_reset() -> void:
	state = BombState.DONE
	set_process(false)
