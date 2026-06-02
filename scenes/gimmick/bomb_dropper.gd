extends Area2D

## 爆弾落下トリガー
## プレイヤーがエリアに侵入すると真上から BombDrop を召喚する
## 落下・着地・爆発は BombDrop 自身が管理する
## 一度だけ発動する

@export_group("BombDropper Settings")
## 召喚する BombDrop シーン
@export var bomb_scene: PackedScene
## スポーン位置のY オフセット（エリア上端からさらに上）
@export var spawn_height_offset: float = 100.0
## 何回侵入したら召喚するか
@export var trigger_count: int = 1

var _triggered: bool = false
var _enter_count: int = 0
var _spawned_bomb: Node = null

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	SignalManager.on_stage_reset.connect(_on_stage_reset)


func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.is_in_group("player"):
		return
	_enter_count += 1
	if _enter_count >= trigger_count:
		_triggered = true
		_spawn_bomb()


func _spawn_bomb() -> void:
	if bomb_scene == null:
		push_warning("BombDropper: bomb_scene が未設定です。")
		return

	var bomb = bomb_scene.instantiate()

	# add_child 前に position を設定（_ready 前に位置確定）
	var area_center_x: float = global_position.x
	var area_top_y: float = global_position.y
	if collision_shape and collision_shape.shape:
		area_top_y = global_position.y - collision_shape.shape.get_rect().size.y / 2.0
	bomb.position = Vector2(area_center_x, area_top_y - spawn_height_offset)

	# 物理クエリのフラッシュ外に add_child する
	get_parent().add_child.call_deferred(bomb)
	_spawned_bomb = bomb


func _on_stage_reset() -> void:
	_triggered = false
	_enter_count = 0
	if is_instance_valid(_spawned_bomb):
		_spawned_bomb.queue_free()
	_spawned_bomb = null
