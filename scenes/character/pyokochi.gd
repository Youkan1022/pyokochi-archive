extends CharacterBody2D
class_name Player

enum PLAYER_STATE {
	IDLE,
	RUN,
	JUMP,
	FALL,
	HIT,
	DUSH,
	WALL_CLING,
	ATTACK
}
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_gravity_flipped: bool = false

# アニメーションスプライトの参照
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# サウンドはAudioManagerシングルトンで管理

# 矢のプリロード
var arrow_scene: PackedScene = preload("res://scenes/character/arrow.tscn")

# 攻撃クールダウン
var attack_cooldown: float = 0.0
var attack_cooldown_max: float = 0.5
@export var arrow_spawn_delay: float = 0.15  # 矢を発生させるまでの遅延（秒）

# 残像用シーン（Sprite2D など）のプリロード
@export var afterimage_scene: PackedScene

# 移動関連の設定
@export_group("move")
@export var move_speed: float = 200.0  # 走り速度をスーパーマリオ風に調整
@export var ground_acceleration: float = 1200.0  # 地面加速を遅くして慣性感を出す
@export var ground_deceleration: float = 1200.0  # 地面減速を遅くして滑りやすく
@export var air_acceleration: float = 1000.0  # 空中加速を地面より遅く
@export var air_deceleration: float = 800.0  # 空中減速を遅くして慣性を残す

# ジャンプ関連の設定
@export_group("jump")
@export var jump_force: float = 250.0  # ジャンプ力をスーパーマリオ風に調整
@export var jump_hold_force: float = 7.5  # ジャンプ長押し時の追加力
@export var max_jump_hold_time: float = 0.5  # ジャンプ長押しの最大時間
@export var max_y_velocity: float = 400.0 # 最大Y速度
@export var max_jump_count: int = 1 # 1で単一ジャンプ
@export var wall_jump_force_x: float = 320.0 # 壁ジャンプ時の水平速度
@export var wall_jump_force_y: float = 280.0 # 壁ジャンプ時の垂直速度
@export_group("wall_cling")
## 壁へ押し付ける速さ（張り付き維持用）
@export var wall_cling_push_speed: float = 40.0
## 壁に張り付いたときの上下移動速度
@export var wall_climb_speed: float = 80.0
@export var wall_cling_duration: float = 2.0  # 壁登り可能な時間（秒）
var wall_cling_time_left: float = 0.0
var wall_cling_locked: bool = false
var can_jump: bool = false # ジャンプ可能かどうか
var jump_count: int = 0
var jump_hold_time: float = 0.0  # ジャンプ長押しの時間

# ダッシュ関連の設定
@export_group("dush")
@export var dush_speed: float = 400.0
@export var dush_duration: float = 0.12
@export var dush_afterimage_interval: float = 0.03
## 上方向を含むダッシュ終了後の上向き速度の上限（Yは上が負なので、この値を超えて上に飛ばない）
@export var dush_exit_max_up_speed: float = 400.0
var dush_time_left: float = 0.0
var dush_afterimage_time_left: float = 0.0
var dush_count: int = 0
var last_dush_dir: Vector2 = Vector2.ZERO

# プレイヤーの移動と状態の管理
var direction: Vector2 = Vector2.ZERO
var dush_direction: Vector2 = Vector2.ZERO
var state: PLAYER_STATE = PLAYER_STATE.IDLE #現在の状態

# 物理処理のメインループ
func _physics_process(delta: float) -> void:
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	# DUSH・壁張り付き中は重力を無効化
	if state != PLAYER_STATE.DUSH and state != PLAYER_STATE.WALL_CLING:
		apply_gravity(delta) # 重力の適用
	fallen_off()
	get_input() # 入力の取得
	apply_movement(delta) # 移動の適用
	move_and_slide() # 移動の適用
	update_state(delta) # 状態の更新

# 重力の適用
func apply_gravity(delta: float):
	# 上向きの風が吹いているときは重力を無効化（疑似無重力）
	if WindManager.is_blowing and WindManager.current_wind.y < 0:
		velocity.y = move_toward(velocity.y, 0.0, abs(GRAVITY) * delta)
		return
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		if is_gravity_flipped:
			velocity.y = max(velocity.y, -max_y_velocity)
		else:
			velocity.y = min(velocity.y, max_y_velocity)

# 重力の反転
func flip_gravity() -> void:
	is_gravity_flipped = !is_gravity_flipped
	GRAVITY *= -1
	up_direction *= -1
	animated_sprite_2d.scale.y *= -1

func fallen_off():
	# 一定距離落下した場合にプレイヤーをヒット状態に
	if global_position.y > 100:
		SignalManager.on_player_hit.emit()
		
# 入力の取得
func get_input():
	# HIT・ATTACK状態中は入力を受け付けない
	if state == PLAYER_STATE.HIT or state == PLAYER_STATE.ATTACK:
		if state == PLAYER_STATE.ATTACK:
			direction = Vector2.ZERO
			dush_direction = Vector2.ZERO
		return
	# 左右の移動
	direction.x = Input.get_axis("left", "right")
	# ダッシュ用の2軸入力（Input Map: up/down を使用）
	dush_direction = Input.get_vector("left", "right", "up", "down")
	
	if state == PLAYER_STATE.DUSH:
		return

	var did_wall_jump := false
	# ジャンプの入力
	if Input.is_action_just_pressed("jump"):
		if is_on_wall() and !is_on_floor():
			apply_wall_jump()
			set_state(PLAYER_STATE.JUMP)
			did_wall_jump = true
		elif jump_count < max_jump_count:
			can_jump = true

	# 壁張り付き（Input Map: wall_cling。長押しで張り付き、離すと解除）
	if state == PLAYER_STATE.WALL_CLING:
		if is_on_floor():
			set_state(PLAYER_STATE.IDLE)
		elif !is_on_wall() or !Input.is_action_pressed("wall_cling"):
			set_state(PLAYER_STATE.FALL)
	elif !did_wall_jump and !wall_cling_locked and Input.is_action_pressed("wall_cling") and is_on_wall() and !is_on_floor():
		set_state(PLAYER_STATE.WALL_CLING)

	# ダッシュ入力（例: "dush" アクション）
	if Input.is_action_just_pressed("dush"):
		start_dush()

	# 攻撃入力（Xキー）
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
		shoot_arrow()

func shoot_arrow() -> void:
	attack_cooldown = attack_cooldown_max
	set_state(PLAYER_STATE.ATTACK)
	AudioManager.play("bow_charge")
	# 発生を遅らせる
	await get_tree().create_timer(arrow_spawn_delay).timeout
	var arrow := arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	var dir := -1.0 if animated_sprite_2d.flip_h else 1.0
	arrow.global_position = global_position + Vector2(dir * 30.0, 0.0)
	arrow.setup(dir)
	# アニメーション終了後に通常状態へ戻す
	await animated_sprite_2d.animation_finished
	if state == PLAYER_STATE.ATTACK:
		if is_on_floor():
			set_state(PLAYER_STATE.IDLE)
		else:
			set_state(PLAYER_STATE.FALL)

func start_dush() -> void:
	if dush_count >= 1:
		return

	# 入力方向へダッシュ（入力なし時は向いている方向へ）
	var dash_dir := dush_direction
	AudioManager.play("dash")
	if dash_dir == Vector2.ZERO:
		dash_dir.x = -1 if animated_sprite_2d.flip_h else 1
	dash_dir = dash_dir.normalized()
	
	if dash_dir == Vector2.ZERO:
		return
	
	set_state(PLAYER_STATE.DUSH)
	last_dush_dir = dash_dir
	dush_time_left = dush_duration
	dush_afterimage_time_left = 0.0
	velocity = dash_dir * dush_speed
	dush_count += 1

func apply_wall_jump() -> void:
	var wall_normal := get_wall_normal()
	if wall_normal == Vector2.ZERO:
		return
	
	# 壁の法線方向に飛ぶ（壁から離れる向き）
	velocity.x = wall_normal.x * wall_jump_force_x
	velocity.y = -wall_jump_force_y
	AudioManager.play("wall_jump")

# 移動の適用
func apply_movement(delta: float):
	# HIT状態中は重力のみ適用、入力や移動は無視
	if state == PLAYER_STATE.HIT:
		return
	
	# ATTACK状態中は入力と行動を無視するが地上では慣性で減速させる
	if state == PLAYER_STATE.ATTACK:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)
		return
	
	if state == PLAYER_STATE.WALL_CLING:
		wall_cling_time_left -= delta
		if wall_cling_time_left <= 0.0:
			wall_cling_locked = true
			set_state(PLAYER_STATE.FALL)
			return

		var wall_n := get_wall_normal()
		if wall_n != Vector2.ZERO:
			# 壁の法線の反対＝壁方向へ押して接触を維持
			velocity.x = -wall_n.x * wall_cling_push_speed
			# 壁登り中は壁側を向くように反転
			animated_sprite_2d.flip_h = wall_n.x > 0.0
		else:
			velocity.x = 0.0
		# 上下入力で壁に沿って移動（up が正の軸になるよう down, up の順）
		var climb_axis := Input.get_axis("down", "up")
		velocity.y = -climb_axis * wall_climb_speed
		if absf(climb_axis) > 0.01:
			if animated_sprite_2d.animation != "wall_cling":
				animated_sprite_2d.animation = "wall_cling"
			animated_sprite_2d.play()
		else:
			animated_sprite_2d.stop()
		return

	if state == PLAYER_STATE.DUSH:
		# DUSH 中は速度を固定（減速・入力の影響なし）
		dush_time_left -= delta
		dush_afterimage_time_left -= delta
		if dush_afterimage_time_left <= 0.0:
			spawn_afterimage()
			dush_afterimage_time_left = dush_afterimage_interval
		if dush_time_left <= 0.0:
			apply_dush_exit_velocity()
			# DUSH 終了後は通常の状態へ
			if is_on_floor():
				set_state(PLAYER_STATE.IDLE)
			else:
				set_state(PLAYER_STATE.FALL)
		return

	if is_on_floor():
		jump_count = 0
		dush_count = 0
		wall_cling_locked = false

	if can_jump:
		velocity.y = -jump_force * sign(GRAVITY) # ジャンプの適用
		can_jump = false
		jump_count += 1
		jump_hold_time = 0.0  # ジャンプ開始時にリセット
		AudioManager.play("jump") # ジャンプ音
	else:
		# ジャンプ長押し処理（空中でジャンプボタンを押している間）
		if !is_on_floor() and Input.is_action_pressed("jump") and jump_hold_time < max_jump_hold_time and velocity.y * sign(GRAVITY) < 0:
			velocity.y -= jump_hold_force * sign(GRAVITY) # 上向きに追加力を加える
			jump_hold_time += delta
		else:
			jump_hold_time = max_jump_hold_time  # 長押し時間を上限に
	
	# 左右移動の処理（ジャンプの有無に関わらず実行）
	var wind_x: float = WindManager.current_wind.x if WindManager.is_blowing else 0.0
	var wind_y: float = WindManager.current_wind.y if WindManager.is_blowing else 0.0
	var current_acceleration := ground_acceleration if is_on_floor() else air_acceleration
	var current_deceleration := ground_deceleration if is_on_floor() else air_deceleration
	if direction.x:
		# プレイヤーの向きを左右反転
		animated_sprite_2d.flip_h = direction.x < 0
		var target_speed := direction.x * move_speed + wind_x
		velocity.x = move_toward(velocity.x, target_speed, current_acceleration * delta)
	else:
		# 停止目標を風速にすることで風に流される
		velocity.x = move_toward(velocity.x, wind_x, current_deceleration * delta)
	# 上向きの風の適用
	if wind_y != 0.0:
		velocity.y = move_toward(velocity.y, wind_y, air_acceleration * delta)


func apply_dush_exit_velocity() -> void:
	# 上方向を含むダッシュ終了後は上向き速度を上限で抑える（Yは上が負）
	if last_dush_dir.y < -0.15:
		velocity.y = max(velocity.y, -dush_exit_max_up_speed)


func spawn_afterimage() -> void:
	if afterimage_scene == null:
		return
	var instance := afterimage_scene.instantiate()
	if instance == null:
		return

	get_tree().current_scene.add_child(instance)
	
	# 残像の見た目を現在のプレイヤーに合わせる
	if instance.has_method("setup_from_sprite"):
		instance.setup_from_sprite(animated_sprite_2d)
	elif instance is Node2D:
		instance.position = global_position


# 状態の更新
func update_state(_delta: float) -> void:
	# DUSH・壁張り付き・HIT・ATTACK中はここでは状態を変えない
	if state == PLAYER_STATE.DUSH or state == PLAYER_STATE.WALL_CLING or state == PLAYER_STATE.HIT or state == PLAYER_STATE.ATTACK:
		return
	
	if is_on_floor():
		if direction.x != 0:
			set_state(PLAYER_STATE.RUN)
		else:
			set_state(PLAYER_STATE.IDLE)
	else:
		if velocity.y > 0:
			set_state(PLAYER_STATE.FALL)
		else:
			set_state(PLAYER_STATE.JUMP)

# 状態の設定
func set_state(new_state: PLAYER_STATE):
	if new_state == state:
		return
	
	state = new_state
	if state == PLAYER_STATE.WALL_CLING:
		wall_cling_time_left = wall_cling_duration

	match state:
		PLAYER_STATE.IDLE:
			animated_sprite_2d.play("idle")
		PLAYER_STATE.RUN:
			animated_sprite_2d.play("run")
		PLAYER_STATE.JUMP:
			animated_sprite_2d.play("jump")
		PLAYER_STATE.FALL:
			animated_sprite_2d.play("fall")
		PLAYER_STATE.HIT:
			animated_sprite_2d.play("down")
		PLAYER_STATE.WALL_CLING:
			animated_sprite_2d.animation = "wall_cling"
			animated_sprite_2d.play()
		PLAYER_STATE.DUSH:
			animated_sprite_2d.play("run") # 必要なら専用アニメに変更
		PLAYER_STATE.ATTACK:
			animated_sprite_2d.play("attack")


func _on_hit_box_area_entered(area: Area2D) -> void:
	# 既にHIT状態なら処理しない（重複実行を防ぐ）
	if state == PLAYER_STATE.HIT:
		return
	
	if area.is_in_group("trap"):
		velocity = Vector2.ZERO
		set_state(PLAYER_STATE.HIT)
		AudioManager.play("damage")
		await get_tree().create_timer(1.5).timeout
		SignalManager.on_player_hit.emit()
		set_state(PLAYER_STATE.IDLE)
