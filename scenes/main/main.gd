extends Node
## Root scene: manages and swaps between game screens (menu, game, settings).

const MENU_SCENE: PackedScene = preload("res://scenes/menu/menu.tscn")
const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")

var _current_scene: Node


func _ready() -> void:
	show_menu()


func show_menu() -> void:
	var menu: MainMenu = MENU_SCENE.instantiate()
	menu.play_pressed.connect(_on_play_pressed)
	menu.quit_pressed.connect(_on_quit_pressed)
	_set_scene(menu)


func _on_play_pressed() -> void:
	_set_scene(GAME_SCENE.instantiate())


func _on_quit_pressed() -> void:
	get_tree().quit()


func _set_scene(new_scene: Node) -> void:
	if _current_scene:
		_current_scene.queue_free()
	add_child(new_scene)
	_current_scene = new_scene
