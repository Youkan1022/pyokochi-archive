extends ParallaxBackground

@onready var sprite_bg: Sprite2D = $ParallaxLayer_bg/Sprite2D_bg
@onready var sprite_deco: Sprite2D = $ParallaxLayer_deco/Sprite2D_deco
@onready var color_rect: ColorRect = $ParallaxLayer_color/ColorRect

@export var bg_texture: CompressedTexture2D
@export var deco_texture: CompressedTexture2D
@export var background_color: Color = Color(0.5, 0.7, 1.0, 1.0)

@export var bg_motion_scale: Vector2 = Vector2(0.7, 1.0)
@export var deco_motion_scale: Vector2 = Vector2(0.7, 1.0)

var _camera: Camera2D

func _ready() -> void:
	$ParallaxLayer_bg.motion_scale = bg_motion_scale
	$ParallaxLayer_deco.motion_scale = deco_motion_scale
	# colorレイヤーは完全固定
	$ParallaxLayer_color.motion_scale = Vector2(1.0, 1.0)
	color_rect.color = background_color
	if bg_texture:
		sprite_bg.texture = bg_texture
	if deco_texture:
		sprite_deco.texture = deco_texture
		sprite_deco.visible = true
	else:
		sprite_deco.visible = false
	_fit_scale()
	await get_tree().process_frame
	_camera = get_viewport().get_camera_2d()

func _fit_scale() -> void:
	if not sprite_bg.texture:
		return
	var viewport_size = get_viewport().get_visible_rect().size
	var tex_size = sprite_bg.texture.get_size()
	var scale_factor = viewport_size.y / tex_size.y
	sprite_bg.scale = Vector2(scale_factor, scale_factor)
	sprite_deco.scale = Vector2(scale_factor, scale_factor)
	$ParallaxLayer_bg.motion_mirroring = Vector2(tex_size.x * scale_factor, 0)
	$ParallaxLayer_deco.motion_mirroring = Vector2(tex_size.x * scale_factor, 0)
	# ColorRectを画面サイズに合わせる
	var viewport_size2 = get_viewport().get_visible_rect().size
	color_rect.size = viewport_size2

func _process(_delta: float) -> void:
	# ColorRectを常にカメラ左上に固定する
	if _camera:
		var viewport_size = get_viewport().get_visible_rect().size
		color_rect.global_position = _camera.global_position - viewport_size / 2.0
