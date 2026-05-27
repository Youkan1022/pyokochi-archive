extends Camera2D

@export var initial_offset: float = 50.0
@export var vertical_offset: float = -80.0
@export var cam_limit_left: int = -10000
@export var cam_limit_right: int = 10000
@export var cam_limit_top: int = -10000
@export var cam_limit_bottom: int = 10000


@export var offset_smooth_speed: float = 1.0

@onready var player: CharacterBody2D = get_parent() as CharacterBody2D

var _current_x_offset: float = 0.0

func _ready() -> void:
	position_smoothing_enabled = false

	limit_left = cam_limit_left
	limit_right = cam_limit_right
	limit_top = cam_limit_top
	limit_bottom = cam_limit_bottom

	var facing_dir = 1.0 if not (player.get_node("AnimatedSprite2D") as AnimatedSprite2D).flip_h else -1.0
	_current_x_offset = facing_dir * initial_offset
	global_position = player.global_position + Vector2(_current_x_offset, vertical_offset)

func _physics_process(_delta: float) -> void:
	var facing_dir = 1.0 if not (player.get_node("AnimatedSprite2D") as AnimatedSprite2D).flip_h else -1.0
	_current_x_offset = lerp(_current_x_offset, facing_dir * initial_offset, offset_smooth_speed * _delta)
	global_position = player.global_position + Vector2(_current_x_offset, vertical_offset)
	global_position = global_position.round()
