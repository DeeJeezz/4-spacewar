extends Node
## Root scene: manages and swaps between game screens (menu, game, settings).

const MENU_SCENE: PackedScene = preload("res://scenes/menu/menu.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const VICTORY_SCENE: PackedScene = preload("res://scenes/victory/victory.tscn")

var _current_scene: Node


func _ready() -> void:
	show_menu()


func show_menu() -> void:
	var menu: MainMenu = MENU_SCENE.instantiate()
	menu.play_pressed.connect(_on_play_pressed)
	menu.quit_pressed.connect(_on_quit_pressed)
	_set_scene(menu)


func _on_play_pressed() -> void:
	var game: GameScene = GAME_SCENE.instantiate()
	game.game_over.connect(_on_game_over)
	_set_scene(game)


func _on_game_over(winner_index: int, score: int) -> void:
	var victory: VictoryScreen = VICTORY_SCENE.instantiate()
	_set_scene(victory)
	victory.setup(winner_index, score)
	victory.restart_pressed.connect(_on_play_pressed)
	victory.menu_pressed.connect(show_menu)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _set_scene(new_scene: Node) -> void:
	if _current_scene:
		_current_scene.queue_free()
	add_child(new_scene)
	_current_scene = new_scene
