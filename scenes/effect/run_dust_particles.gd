extends GPUParticles2D

## 走り中の足元ほこりパーティクル
## pyokochi の子ノードとしてアタッチすること

# ParticleProcessMaterial を GDScript で生成してセットアップ
func _ready() -> void:
	_setup_material()
	emitting = false

func _setup_material() -> void:
	var mat := ParticleProcessMaterial.new()

	# 発射方向：左右にランダムに広がり、少し上に飛ぶ
	mat.direction = Vector3(0, -1, 0)        # 上向きをベース
	mat.spread = 60.0                         # 左右60度に広がる
	mat.initial_velocity_min = 15.0
	mat.initial_velocity_max = 45.0

	# 重力：下に落ちる
	mat.gravity = Vector3(0, 120.0, 0)

	# サイズ：小さめでランダムに
	mat.scale_min = 0.8
	mat.scale_max = 2.2

	# 透明度：フェードアウト
	var color_curve := Gradient.new()
	color_curve.set_color(0, Color(0.85, 0.75, 0.55, 0.75))  # 土っぽい色、半透明で開始
	color_curve.set_color(1, Color(0.85, 0.75, 0.55, 0.0))   # 完全透明でフェード
	var color_ramp := GradientTexture1D.new()
	color_ramp.gradient = color_curve
	mat.color_ramp = color_ramp

	process_material = mat

## RUN 状態になったら呼ぶ（emitting = true）
func start_emitting() -> void:
	emitting = true

## RUN 以外の状態になったら呼ぶ（emitting = false）
func stop_emitting() -> void:
	emitting = false
