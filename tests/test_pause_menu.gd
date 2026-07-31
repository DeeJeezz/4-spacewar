extends Node
## Tests for the pause menu overlay.

const PAUSE_MENU_SCENE: PackedScene = preload("res://scenes/game/pause_menu.tscn")


func test_esc_toggles_pause(framework: RefCounted) -> void:
	var pause_menu: PauseMenu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)
	await get_tree().process_frame
	_teardown_pause()

	var event := InputEventKey.new()
	event.physical_keycode = KEY_ESCAPE
	event.pressed = true
	pause_menu._unhandled_input(event)
	framework.check_true(get_tree().paused, "escape pauses the game")
	framework.check_true(pause_menu.visible, "pause menu is shown while paused")

	pause_menu._unhandled_input(event)
	framework.check_false(get_tree().paused, "second escape resumes the game")
	framework.check_false(pause_menu.visible, "pause menu is hidden after resuming")


func test_resume_button_resumes(framework: RefCounted) -> void:
	var pause_menu: PauseMenu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)
	await get_tree().process_frame
	_teardown_pause()

	pause_menu.pause()
	framework.check_true(get_tree().paused, "pause() pauses the tree")
	var resume_button: Button = pause_menu.get_node("%ResumeButton")
	resume_button.pressed.emit()
	framework.check_false(get_tree().paused, "resume button unpauses the game")
	framework.check_false(pause_menu.visible, "resume button hides the menu")


func test_restart_button_emits(framework: RefCounted) -> void:
	var pause_menu: PauseMenu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)
	await get_tree().process_frame
	_teardown_pause()

	var emitted: Array = []
	pause_menu.restart_pressed.connect(
		func() -> void:
			emitted.append("restart"),
	)
	pause_menu.pause()
	pause_menu.get_node("%RestartButton").pressed.emit()
	framework.check_equal(emitted, ["restart"], "restart button emits restart_pressed")
	framework.check_false(get_tree().paused, "restart resumes before emitting")


func test_menu_button_emits(framework: RefCounted) -> void:
	var pause_menu: PauseMenu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)
	await get_tree().process_frame
	_teardown_pause()

	var emitted: Array = []
	pause_menu.menu_pressed.connect(
		func() -> void:
			emitted.append("menu"),
	)
	pause_menu.pause()
	pause_menu.get_node("%MenuButton").pressed.emit()
	framework.check_equal(emitted, ["menu"], "menu button emits menu_pressed")
	framework.check_false(get_tree().paused, "menu button resumes before emitting")


func _teardown_pause() -> void:
	get_tree().paused = false
