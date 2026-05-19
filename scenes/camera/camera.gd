extends Camera2D

@export var initial_offset: float = 50.0
@export var vertical_offset: float = -80.0
@export var cam_limit_left: int = -10000
@export var cam_limit_right: int = 10000
@export var cam_limit_top: int = -10000
@export var cam_limit_bottom: int = 10000


@onready var player: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	position_smoothing_enabled = false

	limit_left = cam_limit_left
	limit_right = cam_limit_right
	limit_top = cam_limit_top
	limit_bottom = cam_limit_bottom

	var facing_dir = 1.0 if not (player.get_node("AnimatedSprite2D") as AnimatedSprite2D).flip_h else -1.0
	global_position = player.global_position + Vector2(facing_dir * initial_offset, vertical_offset)

func _physics_process(_delta: float) -> void:
	var target := player.global_position + Vector2(0, vertical_offset)
	global_position = target.round()
