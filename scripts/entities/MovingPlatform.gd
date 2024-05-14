extends KinematicBody2D

export var movement_direction: Vector2 = Vector2(1,0)
export var movement_span: int = 4
export var movement_speed: float = 1
export var movement_switch_time: float = 2

var velocity = Vector2(0,0)
var initial_position = Vector2(0,0)
var target_position: Vector2
var positionA: Vector2
var positionB: Vector2

func _ready():
	LevelManager.connect("respawn_world", self, "on_respawn_world")
	movement_direction = movement_direction.normalized()
	initial_position = self.position
	$ChangeDirectionTimer.wait_time = movement_switch_time;
	
	positionA = initial_position + (movement_direction * (movement_span * 2 * LevelManager.PIXELS_PER_TILES))
	positionB = initial_position - (movement_direction * (movement_span * 2 * LevelManager.PIXELS_PER_TILES))
	print("positionA:", positionA, " | positionB:", positionB)
	
	reset()

func reset():
	self.position = positionA;
	target_position = positionB;
	$ChangeDirectionTimer.start()

func _physics_process(delta):
	self.position = lerp(self.position, target_position, movement_speed * delta)

func _on_ChangeDirectionTimer_timeout():
	if target_position == positionA:
		target_position = positionB
	elif target_position == positionB:
		target_position = positionA

func on_respawn_world():
	reset()
