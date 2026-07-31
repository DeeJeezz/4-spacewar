extends Node
## Smoke tests for the Main scene-swap flow.

const MAIN_SCENE: PackedScene = preload("res://scenes/main/main.tscn")


func test_starts_with_menu(framework: RefCounted) -> void:
	var main: Node = _make_main()
	await get_tree().process_frame
	framework.check_true(main._current_scene is MainMenu, "menu is shown on start")


func test_navigation_flow(framework: RefCounted) -> void:
	var main: Node = _make_main()
	await get_tree().process_frame
	framework.check_true(main._current_scene is MainMenu, "menu is shown on start")

	main._on_settings_pressed()
	await get_tree().process_frame
	framework.check_true(main._current_scene is SettingsScreen, "settings opens from the menu")

	main._current_scene.back_pressed.emit()
	await get_tree().process_frame
	framework.check_true(main._current_scene is MainMenu, "back returns to the menu")

	main._on_play_pressed()
	await get_tree().process_frame
	framework.check_true(main._current_scene is GameScene, "game starts from the menu")
	var game: GameScene = main._current_scene
	framework.check_true(game.get_node_or_null("Player1") != null, "player 1 is present")
	framework.check_true(game.get_node_or_null("Player2") != null, "player 2 is present")

	main._on_game_over(1, 300)
	await get_tree().process_frame
	framework.check_true(main._current_scene is VictoryScreen, "victory is shown on game over")
	var victory: VictoryScreen = main._current_scene
	framework.check_equal(
		victory.get_node("%WinnerLabel").text,
		"Победитель: Игрок 1",
		"victory shows the winner",
	)


func _make_main() -> Node:
	var main: Node = MAIN_SCENE.instantiate()
	add_child(main)
	return main
