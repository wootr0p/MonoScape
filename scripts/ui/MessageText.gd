extends Label
class_name MessageText

func _ready():
	LevelManager.connect("respawn_world", self, "on_respawn_world")
	LevelManager.connect("level_win", self, "on_level_win")

func on_respawn_world():
	text = ""

func on_level_win():
	text = "new record!"
