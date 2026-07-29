class_name Wrapped
extends Node

@export var wrap_margin: float = 16.0

var _parent: Node2D


func _ready() -> void:
	_parent = get_parent()


func _process(_delta: float) -> void:
	screen_wrap()


func screen_wrap() -> void:
	if _parent.global_position.x < -wrap_margin:
		_parent.global_position.x = Game.SCREEN_SIZE.x + wrap_margin
	elif _parent.global_position.x > Game.SCREEN_SIZE.x + wrap_margin:
		_parent.global_position.x = -wrap_margin

	if _parent.global_position.y < -wrap_margin:
		_parent.global_position.y = Game.SCREEN_SIZE.y + wrap_margin
	elif _parent.global_position.y > Game.SCREEN_SIZE.y + wrap_margin:
		_parent.global_position.y = -wrap_margin
