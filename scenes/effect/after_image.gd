extends Node2D
@export var life_time: float = 0.2
@export var start_alpha: float = 0.6
@export var tint: Color = Color(0.8, 0.9, 1.0, 1.0)
@onready var sprite_2d: Sprite2D = $Sprite2D
func _ready() -> void:
	if sprite_2d == null:
		queue_free()
		return
	# 最初の色（アルファ含む）
	sprite_2d.modulate = Color(tint.r, tint.g, tint.b, start_alpha)
	# life_time でフェードアウトして削除
	var tw := create_tween()
	tw.tween_property(sprite_2d, "modulate:a", 0.0, life_time)
	tw.finished.connect(queue_free)
func setup_from_sprite(src: AnimatedSprite2D) -> void:
	if sprite_2d == null:
		return
	if src == null or src.sprite_frames == null:
		return
	# プレイヤーの見た目をコピー（現在フレーム）
	var frame_tex := src.sprite_frames.get_frame_texture(src.animation, src.frame)
	sprite_2d.texture = frame_tex
	sprite_2d.flip_h = src.flip_h
	sprite_2d.scale = src.scale
	global_position = src.global_position
	global_rotation = src.global_rotation
