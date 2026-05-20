extends Area2D

var player_nearby: bool = false
var is_active: bool = false

func _ready() -> void:
	$PointLight2D.enabled = false
	$PointLight2D.energy = 0.0
	SignalManager.on_gravity_flipped.connect(_on_gravity_flipped)
	SignalManager.on_stage_reset.connect(_on_stage_reset)
	# 天井設置（Scale Y=-1）の場合、パーティクルの重力を反転
	var material = $GPUParticles2D.process_material.duplicate() as ParticleProcessMaterial
	$GPUParticles2D.process_material = material
	if scale.y < 0:
		material.gravity = Vector3(0, 15, 0)   # 天井用：下方向
	else:
		material.gravity = Vector3(0, -15, 0)  # 通常：上方向
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false

func _process(delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		activate()

func activate():
	SignalManager.on_gravity_flipped.emit(!is_active)

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.flip_gravity()

func _on_gravity_flipped(active: bool) -> void:
	is_active = active
	AudioManager.play("gravity_switch")
	if is_active:
		$PointLight2D.enabled = true
		$GPUParticles2D.emitting = true
		#$GPUParticles2D_circle.emitting = true
		var tween = create_tween()
		tween.tween_property($PointLight2D, "energy", 1.2, 0.3)\
			.set_trans(Tween.TRANS_SINE)
	else:
		$GPUParticles2D.emitting = false
		#$GPUParticles2D_circle.emitting = false
		var tween = create_tween()
		tween.tween_property($PointLight2D, "energy", 0.0, 0.2)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)
		tween.tween_callback($PointLight2D.set.bind("enabled", false))


func _on_stage_reset() -> void:
	is_active = false
	player_nearby = false
	$PointLight2D.enabled = false
	$PointLight2D.energy = 0.0
	$GPUParticles2D.emitting = false
