extends Node

var levelID = -1
var accessLevel = 1

var CONFIG_PATH: String = OS.get_user_data_dir() + "/game_data.cfg"

func increase_access_level():
	accessLevel += 1
	save_to_file()

func is_level_accessible(id):
	return id <= accessLevel and id < 3

func _ready() -> void:
	load_from_file()

func save_to_file():
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	
	config.set_value("Progress", "AccessLevel", accessLevel)
	
	config.save(CONFIG_PATH)

func load_from_file():
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		accessLevel = 1
		return
	
	accessLevel = config.get_value("Progress", "AccessLevel", 1)
