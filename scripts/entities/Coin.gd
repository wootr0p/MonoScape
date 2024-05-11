extends Area2D
class_name Coin

const COIN_TIME_VALUE = 2.0;

var activated = false;

func _ready():
	LevelManager.connect("respawn_world", self, "on_respawn_world")

func collect():
	$AnimationPlayer.play("pickup")
	LevelManager.slow_timer(COIN_TIME_VALUE)

func respawn():
	$AnimationPlayer.play("RESET")

func _on_Area2D_body_entered(body):
	if body is Player:
		collect()

func on_respawn_world():
	respawn()
