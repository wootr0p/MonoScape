extends Node2D

signal respawn_world
signal respawn_player
signal level_complete
signal level_win
signal slow_timer

const RECORD_FILENAME = "user://record.dat"

var current_checkpoint : Checkpoint

var is_level_active = false

var player_start_position : Vector2;
var level_clear : bool = false;
var record_time : float = 99999;

func respawn_player_delayed():
	$Restart_Timer.start()

func respawn(force):
	print("Respawn Player!")
	
	if force || level_clear || !is_instance_valid(current_checkpoint):
		respawn_world();
	else:
		respawn_player();
	

func respawn_world():
	level_clear = false;
	current_checkpoint = null;
	emit_signal("respawn_world");

func respawn_player():
	emit_signal("respawn_player");

func level_complete():
	level_clear = true
	emit_signal("level_complete")

func level_win():
	# NUOVO RECORD
	emit_signal("level_win")
	save_json_to_file()

func slow_timer(amount):
	emit_signal("slow_timer", amount)

func level_init():
	level_clear = false
	load_json_from_file()
	is_level_active = true;

func level_destroy():
	is_level_active = false;
	GameManager.load_menu()

func _process(_delta):
	if is_level_active:
		if Input.is_action_just_released("ui_exit"):
			respawn(true)
		if Input.is_action_just_pressed("ui_home"):
			level_destroy()

func _on_Restart_Timer_timeout():
	respawn(false)

func save_json_to_file():
	var file = File.new()
	file.open(GameManager.GAME_SAVE_FILENAME, File.WRITE)
	
	var json_data = {
		"game_version": GameManager.GAME_VERSION,
		"record_time": record_time
	}
	
	var json_string = JSON.print(json_data)
	file.store_string(json_string)
	
	file.close()

func clear_data_file():
	var dir = Directory.new()
	if dir.file_exists(GameManager.GAME_SAVE_FILENAME):
		dir.remove(GameManager.GAME_SAVE_FILENAME)
	if dir.file_exists(RECORD_FILENAME):
		dir.remove(RECORD_FILENAME)
	

func load_json_from_file():
	var loaded_value = null
	
	var file = File.new()
	if file.file_exists(GameManager.GAME_SAVE_FILENAME):
		file.open(GameManager.GAME_SAVE_FILENAME, File.READ)
		
		var json_string = file.get_as_text()
		var json_data = parse_json(json_string)
		
		if json_data:
			var v
			if json_data.has("game_version"):
				v = json_data["game_version"]
			else:
				v = "unknown"
			
			if v != GameManager.GAME_VERSION && GameManager.GAME_VERSION_CLEAR_RECORD:
				# ELIMINO I DATI
				clear_data_file()
			else:
				# CARICO I DATI
				if json_data.has("record_time"):
					record_time = json_data["record_time"]
		
		file.close()
