extends Node2D

@export var cloud_texture: CompressedTexture2D = preload("res://assets/Rocky Roads/Deco/clouds.png")
@export var cloud_count: int = 6
@export var scroll_speed: float = 30.0
@export var cloud_scale: float = 3.0
## 雲が出現するY範囲（カメラ上端からのオフセット）
@export var min_y_offset: float = 0.0
@export var max_y_ratio: float = 0.6

const CLOUD_WIDTH = 64
const CLOUD_HEIGHT = 16
const CLOUD_TYPES = 3

var _clouds: Array = []
var _viewport_size: Vector2
var _camera: Camera2D
var _initialized: bool = false

func _ready() -> void:
	_viewport_size = get_viewport().get_visible_rect().size
	await get_tree().process_frame
	_camera = get_viewport().get_camera_2d()
	_spawn_clouds()
	_initialized = true

func _get_cam_top_left() -> Vector2:
	if _camera:
		return _camera.global_position - _viewport_size / 2.0
	return -_viewport_size / 2.0

func _spawn_clouds() -> void:
	var cam_tl = _get_cam_top_left()
	for i in range(cloud_count):
		var sprite = Sprite2D.new()
		sprite.texture = cloud_texture
		sprite.region_enabled = true
		var cloud_type = randi() % CLOUD_TYPES
		sprite.region_rect = Rect2(0, cloud_type * CLOUD_HEIGHT, CLOUD_WIDTH, CLOUD_HEIGHT)
		sprite.centered = false
		sprite.scale = Vector2(cloud_scale, cloud_scale)
		# Xは画面幅を雲の数で等間隔に分割し、少しランダムを加える
		var segment = _viewport_size.x / cloud_count
		var rand_x = cam_tl.x + segment * i + randf_range(0, segment)
		var rand_y = cam_tl.y + randf_range(min_y_offset, _viewport_size.y * max_y_ratio)
		sprite.global_position = Vector2(rand_x, rand_y)
		add_child(sprite)
		_clouds.append(sprite)

func _process(delta: float) -> void:
	if not _initialized:
		return
	var cam_tl = _get_cam_top_left()
	var cloud_w = CLOUD_WIDTH * cloud_scale
	for sprite in _clouds:
		sprite.global_position.x -= delta * scroll_speed
		if sprite.global_position.x < cam_tl.x - cloud_w:
			sprite.global_position.x = cam_tl.x + _viewport_size.x + randf_range(0, 200)
			sprite.global_position.y = cam_tl.y + randf_range(min_y_offset, _viewport_size.y * max_y_ratio)
			sprite.region_rect = Rect2(0, randi() % CLOUD_TYPES * CLOUD_HEIGHT, CLOUD_WIDTH, CLOUD_HEIGHT)
