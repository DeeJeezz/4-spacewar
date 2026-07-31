class_name VictoryScreen
extends Control
## Victory screen shown when a player runs out of respawns.
##
## Usage: [br]
## * Call [method setup] with the winner's player index and score. [br]
## * Emits [signal restart_pressed] to start a new round and
## [signal menu_pressed] to return to the main menu.

signal restart_pressed
signal menu_pressed

@onready var _winner_label: Label = %WinnerLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _restart_button: Button = %RestartButton
@onready var _menu_button: Button = %MenuButton


func _ready() -> void:
	_restart_button.pressed.connect(_on_restart_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func setup(winner_index: int, score: int) -> void:
	_winner_label.text = "Победитель: Игрок %d" % winner_index
	_score_label.text = "Очки: %d" % score


func _on_restart_pressed() -> void:
	restart_pressed.emit()


func _on_menu_pressed() -> void:
	menu_pressed.emit()
