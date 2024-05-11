extends Node2D

const GAME_VERSION = "0.1.9"
const GAME_VERSION_CLEAR_RECORD = true

const GAME_SAVE_FILENAME = "user://game.sav"
const GAME_MENU_SCENE = "res://scenes/Main.tscn"


func load_level(level_name):
	var level_path = "res://scenes/levels/" + level_name + ".tscn"
	get_tree().change_scene(level_path)
	LevelManager.level_init(level_name)

func load_menu():
	get_tree().change_scene(GAME_MENU_SCENE)

func save_record_to_file(level, record):
	# Leggo il contenuto del file
	var file = File.new()
	if !file.file_exists(GameManager.GAME_SAVE_FILENAME):
		file.open(GameManager.GAME_SAVE_FILENAME, File.WRITE_READ)
	else:
		file.open(GameManager.GAME_SAVE_FILENAME, File.READ_WRITE)
	
	var json_string = file.get_as_text()
	var json_data
	
	if !json_string:
		# Il file è vuoto
		json_data = {
			"game_version": GameManager.GAME_VERSION,
			"records": {}
		}
	else:
		json_data = JSON.parse(json_string).result
		# Verifica se la chiave "records" esiste nel dizionario
		if !"records" in json_data:
			json_data["records"] = {}
	
	# Scrivo il record
	json_data["records"][level] = record
	json_string = JSON.print(json_data)
	file.store_string(json_string)
	file.close()
	
func load_record_from_file(level):
	LevelManager.record_time = 9999
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
				if json_data.has("records"):
					if json_data["records"].has(level):
						LevelManager.record_time = json_data["records"][level]
		
		file.close()

func clear_data_file():
	# Cancello i record:
	#var dir = Directory.new()
	#if dir.file_exists(GameManager.GAME_SAVE_FILENAME):
	#	dir.remove(GameManager.GAME_SAVE_FILENAME)
		
	# TODO cancellare i vecchi ghost
	pass
