extends Area2D
class_name Spikes

func _on_Spikes_body_entered(body):
	if body.has_method("die"):
		# KILL PLAYER
		body.die()
