class_name GameScene
extends Node2D
## Root node of the game scene.
##
## Usage: [br]
## * Add as a child of [Main] — never instantiated as the main scene. [br]
## * Forwards [signal game_over] from the [RespawnManager] to [Main].

signal game_over(winner_player_index: int, winner_score: int)
signal restart_pressed
signal menu_pressed

@export var ship_textures: Array[Texture2D] = []


func _ready() -> void:
	_assign_ship_textures()
	$RespawnManager.game_over.connect(game_over.emit)
	$PauseMenu.restart_pressed.connect(restart_pressed.emit)
	$PauseMenu.menu_pressed.connect(menu_pressed.emit)


func set_player2_is_ai(is_ai: bool) -> void:
	$Player2.is_ai = is_ai


func _assign_ship_textures() -> void:
	var candidates: Array[Texture2D] = []
	for texture in ship_textures:
		if texture != null:
			candidates.append(texture)
	if candidates.size() < 2:
		push_warning("GameScene needs at least 2 ship textures to give players distinct sprites")
		return
	candidates.shuffle()
	$Player1.set_ship_texture(candidates[0])
	$Player2.set_ship_texture(candidates[1])
