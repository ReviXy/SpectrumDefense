extends Control

@onready var settingsMenu = $SettingsMenu

@onready var musicSlider = $SettingsMenu/HBoxContainer/VBoxContainer2/MusicSlider
@onready var sfxSlider = $SettingsMenu/HBoxContainer/VBoxContainer2/SFXSlider
@onready var fullscreenCheckBox = $SettingsMenu/HBoxContainer/VBoxContainer2/Control2/FullscreenCheckBox
@onready var resolutionDropdown: OptionButton = $SettingsMenu/HBoxContainer/VBoxContainer2/ResolutionDropdown

var resolutions = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
]
var cur_res;

func _ready() -> void:
	musicSlider.connect("value_changed", _on_music_slider_value_changed)
	sfxSlider.connect("value_changed", _on_sfx_slider_value_changed)
	fullscreenCheckBox.connect("toggled", _on_fullscreen_toggled)
	resolutionDropdown.connect("item_selected", _on_resolution_dropdown_item_selected)
	
	resolutionDropdown.clear();
	for resolution in resolutions:
		resolutionDropdown.add_item("%dx%d" % [resolution.x, resolution.y])
		_on_resolution_dropdown_item_selected(0)
	
	var dir = DirAccess.open(OS.get_user_data_dir())
	if dir == null:
		DirAccess.make_dir_absolute(OS.get_user_data_dir())
	
	if !FileAccess.file_exists(PATH):
		save_default()
	load_from_file()

func showSettingsMenu():
	settingsMenu.visible = true

func hideSettingsMenu():
	settingsMenu.visible = false

func _on_music_slider_value_changed(value):
	var busIndex = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(value))

func _on_sfx_slider_value_changed(value):
	var busIndex = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(value))

func _on_fullscreen_toggled(toggle):
	if (toggle):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().size = cur_res

func _on_resolution_dropdown_item_selected(index):
	var new_size = resolutions[index]
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		await get_tree().process_frame
		get_window().size = new_size
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		get_window().size = new_size
	cur_res = new_size;

func _on_save_and_quit_button_pressed() -> void:
	save_to_file()
	hideSettingsMenu()

var PATH: String = OS.get_user_data_dir() + "/settings.cfg"

func save_to_file():
	var config := ConfigFile.new()
	
	config.set_value("Settings", "Music", musicSlider.value)
	config.set_value("Settings", "SFX", sfxSlider.value)
	config.set_value("Settings", "Fullscreen", fullscreenCheckBox.button_pressed)
	config.set_value("Settings", "Resolution", resolutionDropdown.selected)
	
	config.save(PATH)

func save_default():
	var config := ConfigFile.new()
	
	config.set_value("Settings", "Music", 0.5)
	config.set_value("Settings", "SFX", 0.5)
	config.set_value("Settings", "Fullscreen", false)
	config.set_value("Settings", "Resolution", 0)
	
	config.save(PATH)

func load_from_file():
	var config := ConfigFile.new()
	config.load(PATH)

	musicSlider.value = config.get_value("Settings", "Music")
	sfxSlider.value = config.get_value("Settings", "SFX")
	fullscreenCheckBox.button_pressed = config.get_value("Settings", "Fullscreen")
	resolutionDropdown.selected = (config.get_value("Settings", "Resolution"))
	
	musicSlider.emit_signal("value_changed", musicSlider.value)
	sfxSlider.emit_signal("value_changed", sfxSlider.value)
	fullscreenCheckBox.emit_signal("toggled", fullscreenCheckBox.button_pressed)
	resolutionDropdown.emit_signal("item_selected", resolutionDropdown.selected)
