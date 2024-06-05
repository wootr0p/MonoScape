extends Node2D

const GAME_VERSION = "0.3.0b"
const GAME_VERSION_CLEAR_RECORD = true

const GAME_SAVE_FILENAME = "user://game.sav"
const GAME_MENU_SCENE = "res://scenes/Main.tscn"
const GAME_TIME_SCALE = 1

func _ready():
	Engine.time_scale = GAME_TIME_SCALE

func load_level(level_name):
	var level_path = "res://scenes/levels/" + level_name + ".tscn"
	get_tree().change_scene_to_file(level_path)
	LevelManager.level_init(level_name)

func load_menu():
	get_tree().change_scene_to_file(GAME_MENU_SCENE)

func save_record_to_file(level, record):
	var file_path = GameManager.GAME_SAVE_FILENAME
	
	# Struttura dati JSON di default
	var json_data = {
		"game_version": GameManager.GAME_VERSION,
		"records": {}
	}
	var json_string
	
	if FileAccess.file_exists(file_path):
		# Apre il file in lettura
		var file = FileAccess.open(file_path, FileAccess.READ)
		json_string = file.get_as_text()
		file.close()
		
		# Se il file contiene dati, li parso
		if json_string:
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				json_data = json.data
				# Verifico se la chiave "records" esiste nel dizionario, altrimenti la creo
				if !("records" in json_data):
					json_data["records"] = {}
	else:
		# Se il file non esiste, lo creo
		FileAccess.open(file_path, FileAccess.WRITE).close()  # Crea un file vuoto
	
	# Aggiungo o aggiorno il record
	json_data["records"][level] = record
	
	# Converto il dizionario in una stringa JSON
	json_string = JSON.stringify(json_data)
	
	# Apro il file in modalità scrittura e scrivo i dati JSON
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	
func load_record_from_file(level):
	LevelManager.record_time = 9999
	var loaded_value = null
	
	var file;
	if FileAccess.file_exists(GameManager.GAME_SAVE_FILENAME):
		file = FileAccess.open(GameManager.GAME_SAVE_FILENAME, FileAccess.READ)
		
		var json_string = file.get_as_text()
		var json = JSON.new()
		json.parse(json_string)
		var json_data = json.get_data()
		file.close()
		
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
				if json_data.has("records"):
					if json_data["records"].has(level):
						LevelManager.record_time = json_data["records"][level]
		
		

func clear_data_file():
	# Cancello tutti i file nella cartella user data:
	var dir = DirAccess.open("user://");
	if dir == OK:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				dir.remove(file_name)
			file_name = dir.get_next()
