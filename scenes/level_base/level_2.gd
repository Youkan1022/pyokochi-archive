extends Node2D


func _ready() -> void:
	get_tree().paused = false
	# 単体デバッグ時にインデックスを同期
	var current_path = get_tree().current_scene.scene_file_path
	var idx = GameManager.LEVELS.find(current_path)
	if idx != -1:
		GameManager.current_level_index = idx
	SignalManager.on_player_hit.connect(_on_player_hit)
	WindManager.enable_wind(WindManager.WindDirection.LEFT)
	await get_tree().process_frame
	await get_tree().process_frame
	var wind_particles = get_node_or_null("pyokochi/Camera/WindParticles")
	if wind_particles:
		wind_particles.set_theme("forest")
	else:
		push_error("WindParticles not found!")


func _on_player_hit() -> void:
	SignalManager.on_stage_reset.emit()
	WindManager.disable_wind()
	GameManager.load_level_scene()
