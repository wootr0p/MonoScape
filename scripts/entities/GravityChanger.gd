extends Area2D

@export var gravity_restore : bool = false

func _ready():
	LevelManager.connect("respawn_world", Callable(self, "on_respawn_world"))

func _on_GravityChanger_body_entered(body):
	if body is Player:
		$AnimationPlayer.play("pickup")
		LevelManager.flip_gravity(gravity_restore)

func on_respawn_world():
	$AnimationPlayer.play("RESET")
