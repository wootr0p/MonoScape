extends Area2D


func _on_GravityChanger_body_entered(body):
	if body is Player:
		LevelManager.flip_gravity()
