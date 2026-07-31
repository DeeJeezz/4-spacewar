class_name UIManager
extends CanvasLayer
## Displays player scores and remaining respawns on screen.
##
## Usage: [br]
## * Add as a child of the [Game] scene root, next to the [ScoreManager] and the
## [RespawnManager]. [br]
## * Expects the scene to define P1ScoreLabel / P2ScoreLabel and P1RespawnsLabel
## / P2RespawnsLabel nodes with unique names, showing each player's score and
## respawn count in a screen corner.

@onready var _p1_score_label: Label = %P1ScoreLabel
@onready var _p2_score_label: Label = %P2ScoreLabel
@onready var _p1_respawns_label: Label = %P1RespawnsLabel
@onready var _p2_respawns_label: Label = %P2RespawnsLabel
@onready var _score_manager: ScoreManager = get_node("../ScoreManager")
@onready var _respawn_manager: RespawnManager = get_node("../RespawnManager")


func _ready() -> void:
	_score_manager.score_changed.connect(_on_score_changed)
	_respawn_manager.respawns_changed.connect(_on_respawns_changed)
	_p1_respawns_label.text = str(_respawn_manager.respawns_left[1])
	_p2_respawns_label.text = str(_respawn_manager.respawns_left[2])


func _on_score_changed(player_index: int, score: int) -> void:
	match player_index:
		1:
			_p1_score_label.text = str(score)
		2:
			_p2_score_label.text = str(score)


func _on_respawns_changed(player_index: int, respawns_left: int) -> void:
	match player_index:
		1:
			_p1_respawns_label.text = str(respawns_left)
		2:
			_p2_respawns_label.text = str(respawns_left)
