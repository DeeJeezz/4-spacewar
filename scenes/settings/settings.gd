class_name SettingsScreen
extends Control
## Settings screen: adjusts master/music/effects volume.
##
## Reads the current values from the [code]Settings[/code] autoload on ready and
## writes every slider change straight to it (which persists to user data).
## Emits [signal back_pressed] to return to the main menu.

signal back_pressed

@onready var _master_slider: HSlider = %MasterSlider
@onready var _music_slider: HSlider = %MusicSlider
@onready var _effects_slider: HSlider = %EffectsSlider
@onready var _master_value_label: Label = %MasterValueLabel
@onready var _music_value_label: Label = %MusicValueLabel
@onready var _effects_value_label: Label = %EffectsValueLabel
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	_master_slider.value_changed.connect(_on_master_volume_changed)
	_music_slider.value_changed.connect(_on_music_volume_changed)
	_effects_slider.value_changed.connect(_on_effects_volume_changed)
	_load_current_values()


func _load_current_values() -> void:
	_master_slider.value = Settings.master_volume
	_music_slider.value = Settings.music_volume
	_effects_slider.value = Settings.effects_volume
	_update_value_labels()


func _update_value_labels() -> void:
	_master_value_label.text = "%d%%" % int(_master_slider.value * 100.0)
	_music_value_label.text = "%d%%" % int(_music_slider.value * 100.0)
	_effects_value_label.text = "%d%%" % int(_effects_slider.value * 100.0)


func _on_master_volume_changed(value: float) -> void:
	Settings.set_master_volume(value)
	_master_value_label.text = "%d%%" % int(value * 100.0)


func _on_music_volume_changed(value: float) -> void:
	Settings.set_music_volume(value)
	_music_value_label.text = "%d%%" % int(value * 100.0)


func _on_effects_volume_changed(value: float) -> void:
	Settings.set_effects_volume(value)
	_effects_value_label.text = "%d%%" % int(value * 100.0)


func _on_back_pressed() -> void:
	back_pressed.emit()
