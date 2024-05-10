extends Area2D
class_name Checkpoint

var activated = false;

func activate():
	if !activated:
		activated = true;
		GameManager.current_checkpoint = self;
		$AnimationPlayer.play("activate");
		print("Checkpoint activated!")

func reset():
	activated = false;
	$AnimationPlayer.play("RESET");
	print("Checkpoint deactivated!")

func _on_Area2D_body_entered(body):
	if body is KinematicBody2D:
		activate()
