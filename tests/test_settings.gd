extends Node
## Tests for the Settings autoload and its persistence to user://user_data.ini.


func test_defaults_and_buses(framework: RefCounted) -> void:
	_delete_settings_file()
	Settings.load_settings()
	framework.check_almost_equal(
		Settings.master_volume,
		1.0,
		0.001,
		"master volume defaults to 1.0",
	)
	framework.check_almost_equal(Settings.music_volume, 1.0, 0.001, "music volume defaults to 1.0")
	framework.check_almost_equal(
		Settings.effects_volume,
		1.0,
		0.001,
		"effects volume defaults to 1.0",
	)
	framework.check_true(AudioServer.get_bus_index(&"Master") != -1, "Master bus exists")
	framework.check_true(AudioServer.get_bus_index(&"Music") != -1, "Music bus exists")
	framework.check_true(AudioServer.get_bus_index(&"SFX") != -1, "SFX bus exists")


func test_volume_clamped(framework: RefCounted) -> void:
	Settings.set_master_volume(0.5)
	framework.check_almost_equal(Settings.master_volume, 0.5, 0.001, "normal value kept")
	Settings.set_master_volume(2.0)
	framework.check_almost_equal(Settings.master_volume, 1.0, 0.001, "values above 1.0 clamped")
	Settings.set_music_volume(-5.0)
	framework.check_almost_equal(Settings.music_volume, 0.0, 0.001, "negative values clamped to 0")


func test_bus_volume_applied(framework: RefCounted) -> void:
	Settings.set_master_volume(0.25)
	var master_index: int = AudioServer.get_bus_index(&"Master")
	framework.check_almost_equal(
		AudioServer.get_bus_volume_db(master_index),
		linear_to_db(0.25),
		0.001,
		"master bus volume matches linear_to_db",
	)
	Settings.set_effects_volume(0.5)
	var sfx_index: int = AudioServer.get_bus_index(&"SFX")
	framework.check_almost_equal(
		AudioServer.get_bus_volume_db(sfx_index),
		linear_to_db(0.5),
		0.001,
		"effects bus volume matches linear_to_db",
	)


func test_saved_to_disk(framework: RefCounted) -> void:
	_delete_settings_file()
	Settings.set_master_volume(0.4)
	Settings.set_music_volume(0.3)
	Settings.set_effects_volume(0.2)
	framework.check_true(FileAccess.file_exists(Settings.SETTINGS_PATH), "settings file is written")
	var config := ConfigFile.new()
	var error: Error = config.load(Settings.SETTINGS_PATH)
	framework.check_equal(error, OK, "settings file parses")
	framework.check_almost_equal(
		config.get_value("audio", "master"),
		0.4,
		0.001,
		"master value persisted",
	)
	framework.check_almost_equal(
		config.get_value("audio", "music"),
		0.3,
		0.001,
		"music value persisted",
	)
	framework.check_almost_equal(
		config.get_value("audio", "effects"),
		0.2,
		0.001,
		"effects value persisted",
	)


func test_loaded_from_disk(framework: RefCounted) -> void:
	_delete_settings_file()
	Settings.set_master_volume(0.6)
	Settings.set_music_volume(0.6)
	var config := ConfigFile.new()
	config.load(Settings.SETTINGS_PATH)
	config.set_value("audio", "master", 0.7)
	config.save(Settings.SETTINGS_PATH)
	Settings.load_settings()
	framework.check_almost_equal(
		Settings.master_volume,
		0.7,
		0.001,
		"modified file value is loaded",
	)
	framework.check_almost_equal(Settings.music_volume, 0.6, 0.001, "unmodified values are kept")


func _delete_settings_file() -> void:
	DirAccess.remove_absolute(Settings.SETTINGS_PATH)
