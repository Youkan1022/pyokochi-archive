extends CanvasLayer

@onready var label: Label = $Control/Label

func _ready() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_cancel"):
		close()

func set_message(text: String) -> void:
	label.text = text

func close() -> void:
	get_tree().paused = false
	queue_free()
