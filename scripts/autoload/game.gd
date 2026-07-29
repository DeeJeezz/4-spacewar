extends Node

var SCREEN_SIZE: Vector2


func _ready() -> void:
	SCREEN_SIZE = get_viewport().get_visible_rect().size
