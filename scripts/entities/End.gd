extends Area2D

func _on_End_body_entered(body):
	if body is Player:
		LevelManager.level_complete()
