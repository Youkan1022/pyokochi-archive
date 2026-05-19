extends Area2D

@export var speed: float = 400.0
@export var lifetime: float = 1.0

var direction: float = 1.0  # 1.0 = 右, -1.0 = 左

func setup(dir: float) -> void:
	direction = dir
	$Sprite2D.flip_h = (dir < 0.0)

func _ready() -> void:
	# lifetime 後に自動消滅
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta

func _on_body_entered(_body: Node2D) -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	queue_free()
