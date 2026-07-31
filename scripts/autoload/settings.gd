extends Node
## User settings: loads and persists audio volumes to user://user_data.ini.
##
## Audio volumes are stored as linear floats in the 0.0..1.0 range and applied
## to the Master, Music and SFX audio buses via linear_to_db().

const SETTINGS_PATH: String = "user://user_data.ini"
const AUDIO_SECTION: String = "audio"

const BUS_MASTER: StringName = &"Master"
const BUS_MUSIC: StringName = &"Music"
const BUS_SFX: StringName = &"SFX"

const DEFAULT_VOLUME: float = 1.0

var master_volume: float = DEFAULT_VOLUME
var music_volume: float = DEFAULT_VOLUME
var effects_volume: float = DEFAULT_VOLUME


func _ready() -> void:
	_ensure_audio_buses()
	load_settings()
	apply_volumes()


func load_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	master_volume = config.get_value(AUDIO_SECTION, "master", DEFAULT_VOLUME)
	music_volume = config.get_value(AUDIO_SECTION, "music", DEFAULT_VOLUME)
	effects_volume = config.get_value(AUDIO_SECTION, "effects", DEFAULT_VOLUME)


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_volume(BUS_MASTER, master_volume)
	save_settings()


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_volume(BUS_MUSIC, music_volume)
	save_settings()


func set_effects_volume(value: float) -> void:
	effects_volume = clampf(value, 0.0, 1.0)
	_apply_volume(BUS_SFX, effects_volume)
	save_settings()


func apply_volumes() -> void:
	_apply_volume(BUS_MASTER, master_volume)
	_apply_volume(BUS_MUSIC, music_volume)
	_apply_volume(BUS_SFX, effects_volume)


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(AUDIO_SECTION, "master", master_volume)
	config.set_value(AUDIO_SECTION, "music", music_volume)
	config.set_value(AUDIO_SECTION, "effects", effects_volume)
	config.save(SETTINGS_PATH)


func _ensure_audio_buses() -> void:
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_MUSIC)
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_SFX)


func _apply_volume(bus_name: StringName, volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))
