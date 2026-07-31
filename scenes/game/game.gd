class_name GameScene
extends Node2D
## Root node of the game scene.
##
## Usage: [br]
## * Add as a child of [Main] — never instantiated as the main scene. [br]
## * Forwards [signal game_over] from the [RespawnManager] to [Main].

signal game_over(winner_player_index: int, winner_score: int)


func _ready() -> void:
	$RespawnManager.game_over.connect(game_over.emit)
