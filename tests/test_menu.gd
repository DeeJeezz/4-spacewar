extends Node
## Tests for the main menu screen.

const MENU_SCENE: PackedScene = preload("res://scenes/menu/menu.tscn")


func test_signals_on_button_press(framework: RefCounted) -> void:
	var menu: MainMenu = MENU_SCENE.instantiate()
	add_child(menu)
	var emitted: Array = []
	menu.play_pressed.connect(
		func() -> void:
			emitted.append("play"),
	)
	menu.settings_pressed.connect(
		func() -> void:
			emitted.append("settings"),
	)
	menu.quit_pressed.connect(
		func() -> void:
			emitted.append("quit"),
	)
	var play_button: Button = menu.get_node("%PlayButton")
	var settings_button: Button = menu.get_node("%SettingsButton")
	var quit_button: Button = menu.get_node("%QuitButton")
	play_button.pressed.emit()
	settings_button.pressed.emit()
	quit_button.pressed.emit()
	framework.check_equal(
		emitted,
		["play", "settings", "quit"],
		"all three buttons emit their signals",
	)
