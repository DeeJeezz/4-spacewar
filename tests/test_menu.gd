extends Node
## Tests for the main menu screen.

const MENU_SCENE: PackedScene = preload("res://scenes/menu/menu.tscn")


func test_signals_on_button_press(framework: RefCounted) -> void:
	var menu: MainMenu = MENU_SCENE.instantiate()
	add_child(menu)
	var emitted: Array = []
	menu.multiplayer_pressed.connect(
		func() -> void:
			emitted.append("multiplayer"),
	)
	menu.vs_ai_pressed.connect(
		func() -> void:
			emitted.append("vs_ai"),
	)
	menu.settings_pressed.connect(
		func() -> void:
			emitted.append("settings"),
	)
	menu.quit_pressed.connect(
		func() -> void:
			emitted.append("quit"),
	)
	var multiplayer_button: Button = menu.get_node("%MultiplayerButton")
	var vs_ai_button: Button = menu.get_node("%VsAiButton")
	var settings_button: Button = menu.get_node("%SettingsButton")
	var quit_button: Button = menu.get_node("%QuitButton")
	multiplayer_button.pressed.emit()
	vs_ai_button.pressed.emit()
	settings_button.pressed.emit()
	quit_button.pressed.emit()
	framework.check_equal(
		emitted,
		["multiplayer", "vs_ai", "settings", "quit"],
		"all four buttons emit their signals",
	)
