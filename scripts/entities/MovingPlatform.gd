extends AnimatableBody2D

@export var movement_direction: Vector2 = Vector2(1,0)
@export var movement_span: float = 4
@export var movement_speed: float = 1
@export var movement_switch_time: float = 2

@onready var ChangeDirectionTimer = $ChangeDirectionTimer

var velocity = Vector2(0,0)
var initial_position = Vector2(0,0)
var target_position: Vector2
var positionA: Vector2
var positionB: Vector2
var prev_pos: Vector2
var next_pos: Vector2
var stop_sound_played : bool = true

func _ready():
	LevelManager.connect("respawn_world", Callable(self, "on_respawn_world"))
	movement_direction = movement_direction.normalized()
	initial_position = self.position
	ChangeDirectionTimer.wait_time = movement_switch_time;
	
	positionA = initial_position + (movement_direction * (movement_span * 2 * LevelManager.PIXELS_PER_TILES))
	positionB = initial_position - (movement_direction * (movement_span * 2 * LevelManager.PIXELS_PER_TILES))
	print("positionA:", positionA, " | positionB:", positionB)
	
	reset()

func reset():
	self.position = positionA;
	target_position = positionB;
	stop_sound_played = true;
	ChangeDirectionTimer.start()

func _physics_process(delta):
	prev_pos = self.position;
	next_pos = lerp(prev_pos, target_position, movement_speed * delta)
	velocity = (next_pos - prev_pos)
	
	#move_and_collide(velocity)
	self.position = next_pos

func _process(_delta):
	# Gestione del suono
#	if velocity.length() > 0.5:
#		if !$Moving_Sound.playing:
#			$Moving_Sound.playing = true;
#			$Stop_Sound.playing = false;
#			stop_sound_played = false
#	else:
#		if $Moving_Sound.playing:
#			$Moving_Sound.playing = false;
#		if !$Stop_Sound.playing && !stop_sound_played:
#			$Stop_Sound.playing = true;
#			stop_sound_played = true
	pass

func _on_ChangeDirectionTimer_timeout():
	if target_position == positionA:
		target_position = positionB
	elif target_position == positionB:
		target_position = positionA

func on_respawn_world():
	reset()
