extends Area2D
class_name Checkpoint

@export var upside_down : bool = false

var activated = false;

func _ready():
	LevelManager.connect("respawn_world", Callable(self, "on_respawn_world"))

func activate():
	if !activated:
		activated = true;
		$AnimationPlayer.play("activate");
		print("Checkpoint activated!")
		LevelManager.checkpoint_activated(self)

func reset():
	activated = false;
	$AnimationPlayer.play("RESET");
	print("Checkpoint deactivated!")

func _on_Area2D_body_entered(body):
	if body is Player:
		if (upside_down && LevelManager.gravity_sign < 0) || (!upside_down && LevelManager.gravity_sign > 0):
			activate()

func on_respawn_world():
	reset()
