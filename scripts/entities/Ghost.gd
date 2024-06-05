extends Node2D

var ghost_positions_playback = []
var ghost_positions_record = []
var ghost_positions = []
var playback_index = 0

var player

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	ghost_positions_playback = load_from_file()
	$AnimatedSprite2D.visible = (ghost_positions_playback.size() > 0)
	
	LevelManager.connect("respawn_world", Callable(self, "on_respawn_world"))
	LevelManager.connect("level_win", Callable(self, "on_level_win"))

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
	
	$AnimatedSprite2D.visible = (ghost_positions_playback.size() > 0)

func save(pos):
	ghost_positions.append(pos)

func new_record():
	print("NEW_RECORD!")
	
	ghost_positions_record.clear()
	for element in ghost_positions:
		ghost_positions_record.append(element)
		
	save_to_file(ghost_positions_record)
	

func save_to_file(array_to_save):
	var file = FileAccess.open(LevelManager.ghost_level_save_path, FileAccess.WRITE)
	
	# Scrivi ogni elemento dell'array nel file
	for vector in array_to_save:
		file.store_line(str(vector.x) + "," + str(vector.y))
	
	file.close()

func load_from_file():
	var array_loaded = []
	
	var file;
	if FileAccess.file_exists(LevelManager.ghost_level_save_path):
		file = FileAccess.open(LevelManager.ghost_level_save_path, FileAccess.READ)
		
		while !file.eof_reached():
			var line = file.get_line()
			if line:
				var vector_components = line.split(",")
				var vector = Vector2(float(vector_components[0]), float(vector_components[1]))
				array_loaded.append(vector)
		
		file.close()
	
	return array_loaded


func _physics_process(_delta):
	if LevelManager.is_level_active:
		if !LevelManager.level_clear:
			save(player.position)
		step()

func on_respawn_world():
	reset()

func on_level_win():
	new_record()
