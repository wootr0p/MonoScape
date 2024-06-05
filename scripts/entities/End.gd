extends Area2D

func _on_End_body_entered(body):
	print(body)
	if body is Player:
		LevelManager.handle_level_complete()
