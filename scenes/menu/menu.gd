class_name MainMenu
extends Control
## Main menu screen.

signal multiplayer_pressed
signal vs_ai_pressed
signal settings_pressed
signal quit_pressed

@onready var _multiplayer_button: BaseButton = %MultiplayerButton
@onready var _vs_ai_button: BaseButton = %VsAiButton
@onready var _settings_button: BaseButton = %SettingsButton
@onready var _quit_button: BaseButton = %QuitButton


func _ready() -> void:
	_multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	_vs_ai_button.pressed.connect(_on_vs_ai_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_multiplayer_pressed() -> void:
	multiplayer_pressed.emit()


func _on_vs_ai_pressed() -> void:
	vs_ai_pressed.emit()


func _on_settings_pressed() -> void:
	settings_pressed.emit()


func _on_quit_pressed() -> void:
	quit_pressed.emit()
