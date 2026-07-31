extends Node
## Tests for the victory screen.

const VICTORY_SCENE: PackedScene = preload("res://scenes/victory/victory.tscn")


func test_setup_fills_labels(framework: RefCounted) -> void:
	var victory: VictoryScreen = VICTORY_SCENE.instantiate()
	add_child(victory)
	victory.setup(2, 300)
	framework.check_equal(
		victory.get_node("%WinnerLabel").text,
		"Победитель: Игрок 2",
		"winner label is filled",
	)
	framework.check_equal(
		victory.get_node("%ScoreLabel").text,
		"Очки: 300",
		"score label is filled",
	)


func test_buttons_emit_signals(framework: RefCounted) -> void:
	var victory: VictoryScreen = VICTORY_SCENE.instantiate()
	add_child(victory)
	var emitted: Array = []
	victory.restart_pressed.connect(
		func() -> void:
			emitted.append("restart"),
	)
	victory.menu_pressed.connect(
		func() -> void:
			emitted.append("menu"),
	)
	var restart_button: Button = victory.get_node("%RestartButton")
	var menu_button: Button = victory.get_node("%MenuButton")
	restart_button.pressed.emit()
	menu_button.pressed.emit()
	framework.check_equal(emitted, ["restart", "menu"], "both buttons emit their signals")
