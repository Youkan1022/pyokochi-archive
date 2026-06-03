extends Sprite2D

@export var message_scene: PackedScene

var _player_near: bool = false

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if _player_near and Input.is_action_just_pressed("interact"):
		_open_message()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_near = false

func _open_message() -> void:
	if message_scene == null:
		return
	var msg = message_scene.instantiate()
	get_tree().root.add_child(msg)
	get_tree().paused = true
