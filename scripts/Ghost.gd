extends Node2D
class_name Ghost

var ghost_positions_playback = []
var ghost_positions_record = []
var ghost_positions = []
var playback_index = 0

func _ready():
	GameManager.ghost = self
	
	ghost_positions_playback = load_from_file()
	$AnimatedSprite.visible = (ghost_positions_playback.size() > 0)

func step():
	if playback_index < ghost_positions_playback.size():
		position = ghost_positions_playback[playback_index]
		playback_index += 1

func reset():
	playback_index = 0
	ghost_positions.clear()
	
	# copio array del record nel playback
	if ghost_positions_record.size() > 0:
		ghost_positions_playback.clear()
		for element in ghost_positions_record:
			ghost_positions_playback.append(element)
	
	$AnimatedSprite.visible = (ghost_positions_playback.size() > 0)

func save(pos):
	ghost_positions.append(pos)

func new_record():
	print("NEW_RECORD!")
	
	ghost_positions_record.clear()
	for element in ghost_positions:
		ghost_positions_record.append(element)
		
	save_to_file(ghost_positions_record)
	

func save_to_file(array_to_save):
	var file = File.new()
	file.open(GameManager.RECORD_FILENAME, File.WRITE)
	
	# Scrivi ogni elemento dell'array nel file
	for vector in array_to_save:
		file.store_line(str(vector.x) + "," + str(vector.y))
	
	file.close()

func load_from_file():
	var array_loaded = []
	
	var file = File.new()
	if file.file_exists(GameManager.RECORD_FILENAME):
		file.open(GameManager.RECORD_FILENAME, File.READ)
		
		while !file.eof_reached():
			var line = file.get_line()
			if line:
				var vector_components = line.split(",")
				var vector = Vector2(float(vector_components[0]), float(vector_components[1]))
				array_loaded.append(vector)
		
		file.close()
	
	return array_loaded
