extends Node2D

const GAME_VERSION = "0.1.8"
const GAME_VERSION_CLEAR_RECORD = true

const GAME_SAVE_FILENAME = "user://game.sav"
const GAME_MENU_SCENE = "res://scenes/Main.tscn"


func load_level(level_name):
	var level_path = "res://scenes/levels/" + level_name + ".tscn"
	get_tree().change_scene(level_path)
	LevelManager.level_init()
	#call_deferred("_deferred_switch_scene", level_path, true)
	

func load_menu():
	get_tree().change_scene(GAME_MENU_SCENE)
	#call_deferred("_deferred_switch_scene", GAME_MENU_SCENE, false)

func _deferred_switch_scene(path, isLevel):
	get_tree().change_scene(path)
	if isLevel:
		LevelManager.level_init()
