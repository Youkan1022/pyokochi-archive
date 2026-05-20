extends Node2D


func _ready() -> void:
	get_tree().paused = false
	SignalManager.on_player_hit.connect(_on_player_hit)
	#WindManager.enable_wind(WindManager.WindDirection.RIGHT)
	#$pyokochi/Camera/WindParticles.set_theme("dirt")


func _on_player_hit() -> void:
	SignalManager.on_stage_reset.emit()
	GameManager.load_level_scene()
