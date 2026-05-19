extends ParallaxBackground

@onready var sprite_2d_sky: Sprite2D = $ParallaxLayer/Sprite2D_sky
@onready var sprite_2d_mount: Sprite2D = $ParallaxLayer/Sprite2D_mount
@onready var sprite_2d_cloud: Sprite2D = $ParallaxLayer/Sprite2D_cloud

@export var sky_texture: CompressedTexture2D = preload("res://assets/TileSet/GrassFieldTileSet/full_spritesheet/BG_Sky.png")
@export var mount_texture:CompressedTexture2D = preload("res://assets/TileSet/GrassFieldTileSet/full_spritesheet/BG_Mountain.png")
@export var cloud_texture:CompressedTexture2D = preload("res://assets/TileSet/GrassFieldTileSet/full_spritesheet/BG_Cloud.png")
@export var scroll_speed = 5
@export var mount_scroll_speed = 2.0  # sky より遅い速度
@export var cloud_scroll_speed = 3.5  # mount より速い速度

func _ready() -> void:
	sprite_2d_sky.texture = sky_texture
	sprite_2d_mount.texture = mount_texture
	sprite_2d_cloud.texture = cloud_texture
	

func _process(delta: float) -> void:
	# sprite_2d_cloud も流れるように動く（視差効果）
	sprite_2d_cloud.position.x -= delta * cloud_scroll_speed
	
	# クラウドのテクスチャサイズを取得してリピート処理
	if sprite_2d_cloud.texture:
		var cloud_texture_width = sprite_2d_cloud.texture.get_width()
		if sprite_2d_cloud.position.x < -cloud_texture_width:
			sprite_2d_cloud.position.x += cloud_texture_width
