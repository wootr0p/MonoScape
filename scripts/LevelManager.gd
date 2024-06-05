extends Node2D

signal respawn_world
signal respawn_player
signal level_complete
signal level_win
signal slow_timer
signal gravity_flipped

const GRAVITY = 800
const FALL_GRAVITY_MUL = 1.2
const PIXELS_PER_TILES = 8

var current_checkpoint : Checkpoint

var level_name = ""
var ghost_level_save_path = "";
var is_level_active = false

var gravity : float = GRAVITY
var gravity_sign: int = +1
var checkpoint_gravity: float

var player_start_position : Vector2;
var level_clear : bool = false;
var record_time : float = 99999;

func respawn_player_delayed():
	$Restart_Timer.start()

func respawn(force):
	if $Restart_Timer.is_stopped():
		print("Respawn Player!")
		
		if force || level_clear || !is_instance_valid(current_checkpoint):
			handle_respawn_world();
		else:
			handle_respawn_player();
	

func handle_respawn_world():
	level_clear = false;
	current_checkpoint = null;
	gravity = GRAVITY
	gravity_sign = sign(gravity)
	emit_signal("respawn_world");

func handle_respawn_player():
	gravity = checkpoint_gravity
	gravity_sign = sign(gravity)
	emit_signal("respawn_player");

func handle_level_complete():
	print("LEVEL COMPLETE!")
	level_clear = true
	emit_signal("level_complete")

func handle_level_win():
	# NUOVO RECORD
	emit_signal("level_win")
	GameManager.save_record_to_file(level_name, record_time)

func handle_slow_timer(amount):
	emit_signal("slow_timer", amount)

func level_init(lvl_name):
	checkpoint_gravity = gravity
	gravity_sign = sign(gravity)
	level_name = lvl_name
	ghost_level_save_path = "user://" + level_name + "_ghost.dat"
	level_clear = false
	GameManager.load_record_from_file(level_name)
	is_level_active = true;
	handle_respawn_world()

func level_destroy():
	is_level_active = false;
	GameManager.load_menu()

func flip_gravity(gravity_restore):
	print("FLIP_GRAVITY ", gravity_restore)
	if (gravity_restore):
		gravity = GRAVITY
	else:
		gravity = -GRAVITY
	gravity_sign = sign(gravity)
	emit_signal("gravity_flipped")

func checkpoint_activated(checkpoint):
	current_checkpoint = checkpoint;
	checkpoint_gravity = gravity;
	

func _process(_delta):
	if Input.is_action_just_released("ui_exit"):
		respawn(true)
	if Input.is_action_just_pressed("ui_home"):
		level_destroy()

func get_gravity(velocity) -> float:
	# in base a se sto cadendo o no ho una gravità diversa
	return gravity if velocity.y < 0 else gravity * FALL_GRAVITY_MUL;

func _on_Restart_Timer_timeout():
	respawn(false)
