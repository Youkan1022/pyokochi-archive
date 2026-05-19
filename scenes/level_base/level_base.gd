extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false
	WindManager.enable_wind(WindManager.WindDirection.RIGHT)
	$pyokochi/Camera/WindParticles.set_theme("dirt")
