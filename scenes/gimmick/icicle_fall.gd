extends Node2D

## つらら落下オブジェクト
## IcicleCeiling から召喚され、落下して地面で割れて消滅する

signal finished  # 割れアニメ完了 → IcicleCeiling に通知

var _fall_velocity: float = 0.0

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_shape: CollisionShape2D = $DamageArea/CollisionShape2D
@onready var ground_ray: RayCast2D = $GroundRay


func _ready() -> void:
	sprite.play("fall")
	damage_shape.disabled = false


func _process(delta: float) -> void:
	_fall_velocity += GRAVITY * delta
	var dy: float = _fall_velocity * delta
	position.y += dy
	if ground_ray.is_colliding():
		_on_hit_ground()


func _on_hit_ground() -> void:
	set_process(false)
	# 当たり判定を即座に削除
	damage_shape.set_deferred("disabled", true)
	sprite.play("break")
	await sprite.animation_finished
	finished.emit()
	queue_free()
