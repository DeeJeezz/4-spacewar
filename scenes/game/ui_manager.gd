class_name UIManager
extends CanvasLayer
## Displays player scores on screen.
##
## Usage: [br]
## * Add as a child of the [Game] scene root, next to the [ScoreManager]. [br]
## * Expects the scene to define P1ScoreLabel / P2ScoreLabel nodes with unique
## names, showing each player's score in a screen corner.

@onready var _p1_score_label: Label = %P1ScoreLabel
@onready var _p2_score_label: Label = %P2ScoreLabel
@onready var _score_manager: ScoreManager = get_node("../ScoreManager")


func _ready() -> void:
	_score_manager.score_changed.connect(_on_score_changed)


func _on_score_changed(player_index: int, score: int) -> void:
	match player_index:
		1:
			_p1_score_label.text = str(score)
		2:
			_p2_score_label.text = str(score)
