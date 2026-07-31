class_name PauseMenu
extends CanvasLayer
## Pause overlay shown while the game is paused.
##
## Usage: [br]
## * Add as a child of the [Game] scene root, above the UI layer. [br]
## * Has [constant Node.PROCESS_MODE_ALWAYS] so its buttons and the Escape key
## keep working while the scene tree is paused. [br]
## * Toggled with the [code]pause[/code] input action. Emits [signal restart_pressed]
## to start a new round and [signal menu_pressed] to return to the main menu.

signal restart_pressed
signal menu_pressed

@onready var _resume_button: Button = %ResumeButton
@onready var _restart_button: Button = %RestartButton
@onready var _menu_button: Button = %MenuButton


func _ready() -> void:
	visible = false
	_resume_button.pressed.connect(_on_resume_pressed)
	_restart_button.pressed.connect(_on_restart_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause() -> void:
	if get_tree().paused:
		resume()
	else:
		pause()


func pause() -> void:
	visible = true
	get_tree().paused = true


func resume() -> void:
	visible = false
	get_tree().paused = false


func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	resume()
	restart_pressed.emit()


func _on_menu_pressed() -> void:
	resume()
	menu_pressed.emit()
