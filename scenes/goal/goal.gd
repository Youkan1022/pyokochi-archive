extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		AudioManager.play("goal")
		SignalManager.on_game_complete.emit()
		print("Goal")
