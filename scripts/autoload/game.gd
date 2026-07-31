extends Node
## Main game state.

var SCREEN_SIZE: Vector2


func _ready() -> void:
	_update_screen_size()


func _update_screen_size() -> void:
	if DisplayServer.get_name() == "headless":
		return

	var size: Vector2 = get_viewport().get_visible_rect().size
	if size.x > 0.0 and size.y > 0.0:
		SCREEN_SIZE = size
