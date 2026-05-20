extends GPUParticles2D

@export var canvas_item_material: CanvasItemMaterial
@export var leaf_spring_texture: Texture2D
@export var dirt_texture: Texture2D
@export var desert_texture: Texture2D
@export var snow_texture: Texture2D
@export var lava_texture: Texture2D

func _ready() -> void:
	emitting = false
	WindManager.on_wind_changed.connect(_on_wind_changed)
	WindManager.on_wind_coming.connect(_on_wind_coming)

var _wind_active: bool = false

# 風が来る1秒前に呼ばれる
func _on_wind_coming(wind: Vector2) -> void:
	var material = process_material as ParticleProcessMaterial
	if material:
		var dir = wind.normalized()
		material.direction = Vector3(dir.x, dir.y, 0)
	emitting = true

# 風が実際に変化したとき（止まるときもここで受け取る）
func _on_wind_changed(wind: Vector2) -> void:
	if wind == Vector2.ZERO:
		emitting = false

func set_theme(theme: String) -> void:
	var mat = process_material.duplicate() as ParticleProcessMaterial
	process_material = mat
	
	match theme:
		"forest":
			texture = leaf_spring_texture
			material = canvas_item_material
		"dirt":
			texture = dirt_texture
			modulate = Color(0.65, 0.25, 0.1)
			material = null
			mat.scale_min = 0.5
			mat.scale_max = 1.0
		"desert":
			texture = desert_texture
			modulate = Color(1.0, 0.85, 0.5)
			material = null
			mat.scale_min = 0.5
			mat.scale_max = 1.0
		"snow":
			texture = snow_texture
			material = canvas_item_material
		"lava":
			texture = lava_texture
			material = canvas_item_material
			
