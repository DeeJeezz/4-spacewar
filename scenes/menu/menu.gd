class_name MainMenu
extends Control
## Main menu screen.

signal play_pressed
signal settings_pressed
signal quit_pressed

@onready var _play_button: BaseButton = %PlayButton
@onready var _settings_button: BaseButton = %SettingsButton
@onready var _quit_button: BaseButton = %QuitButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	play_pressed.emit()


func _on_settings_pressed() -> void:
	settings_pressed.emit()


func _on_quit_pressed() -> void:
	quit_pressed.emit()
