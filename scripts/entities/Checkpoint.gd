extends Area2D
class_name Checkpoint

var activated = false;

func _ready():
	LevelManager.connect("respawn_world", self, "on_respawn_world")

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
	if body is KinematicBody2D:
		activate()

func on_respawn_world():
	reset()
