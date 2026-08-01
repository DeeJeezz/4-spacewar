extends Node
## Root scene: manages and swaps between game screens (menu, game, settings).

const MENU_SCENE: PackedScene = preload("res://scenes/menu/menu.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://scenes/settings/settings.tscn")
const VICTORY_SCENE: PackedScene = preload("res://scenes/victory/victory.tscn")

var _current_scene: Node

var _player2_is_ai: bool = true


func _ready() -> void:
	show_menu()


func show_menu() -> void:
	var menu: MainMenu = MENU_SCENE.instantiate()
	menu.multiplayer_pressed.connect(_on_multiplayer_pressed)
	menu.vs_ai_pressed.connect(_on_vs_ai_pressed)
	menu.settings_pressed.connect(_on_settings_pressed)
	menu.quit_pressed.connect(_on_quit_pressed)
	_set_scene(menu)


func _on_multiplayer_pressed() -> void:
	_start_game(false)


func _on_vs_ai_pressed() -> void:
	_start_game(true)


func _start_game(player2_is_ai: bool) -> void:
	_player2_is_ai = player2_is_ai
	var game: GameScene = GAME_SCENE.instantiate()
	game.set_player2_is_ai(player2_is_ai)
	game.game_over.connect(_on_game_over)
	game.restart_pressed.connect(_start_game.bind(player2_is_ai))
	game.menu_pressed.connect(show_menu)
	_set_scene(game)


func _on_settings_pressed() -> void:
	var settings: SettingsScreen = SETTINGS_SCENE.instantiate()
	settings.back_pressed.connect(show_menu)
	_set_scene(settings)


func _on_game_over(winner_index: int, score: int) -> void:
	var victory: VictoryScreen = VICTORY_SCENE.instantiate()
	_set_scene(victory)
	victory.setup(winner_index, score)
	victory.restart_pressed.connect(_start_game.bind(_player2_is_ai))
	victory.menu_pressed.connect(show_menu)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _set_scene(new_scene: Node) -> void:
	if _current_scene:
		_current_scene.queue_free()
	add_child(new_scene)
	_current_scene = new_scene
