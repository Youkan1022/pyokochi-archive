extends "res://scenes/level_base/level_base.gd"

## level2 固有設定：左向きの風 + forest パーティクル


func _level_setup() -> void:
	WindManager.enable_wind(WindManager.WindDirection.LEFT)
	await get_tree().process_frame
	await get_tree().process_frame
	var wind_particles = get_node_or_null("pyokochi/Camera/WindParticles")
	if wind_particles:
		wind_particles.set_theme("forest")
	else:
		push_error("WindParticles not found!")
