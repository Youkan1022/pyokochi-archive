extends ParallaxBackground

@onready var sprite_bg: Sprite2D = $ParallaxLayer_bg/Sprite2D_bg
@onready var sprite_deco: Sprite2D = $ParallaxLayer_deco/Sprite2D_deco

@export var bg_texture: CompressedTexture2D
@export var deco_texture: CompressedTexture2D

@export var bg_motion_scale: Vector2 = Vector2(0.7, 1.0)
@export var deco_motion_scale: Vector2 = Vector2(0.7, 1.0)

func _ready() -> void:
	$ParallaxLayer_bg.motion_scale = bg_motion_scale
	$ParallaxLayer_deco.motion_scale = deco_motion_scale
	if bg_texture:
		sprite_bg.texture = bg_texture
	if deco_texture:
		sprite_deco.texture = deco_texture
		sprite_deco.visible = true
	else:
		sprite_deco.visible = false
	_fit_scale()

func _fit_scale() -> void:
	if not sprite_bg.texture:
		return
	var viewport_size = get_viewport().get_visible_rect().size
	var tex_size = sprite_bg.texture.get_size()
	var scale_factor = viewport_size.y / tex_size.y
	sprite_bg.scale = Vector2(scale_factor, scale_factor)
	sprite_deco.scale = Vector2(scale_factor, scale_factor)
	var node_scale_x = scale.x
	$ParallaxLayer_bg.motion_mirroring = Vector2(tex_size.x * scale_factor * node_scale_x, 0)
	$ParallaxLayer_deco.motion_mirroring = Vector2(tex_size.x * scale_factor * node_scale_x, 0)
