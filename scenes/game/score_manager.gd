class_name ScoreManager
extends Node
## Tracks player scores.
##
## Usage: [br]
## * Add as a child of the [Game] scene root. [br]
## * Listens to each [Player]'s [Hurtbox] and [Health] signals: hitting an enemy
## ship grants [constant HIT_POINTS], destroying one grants [constant KILL_POINTS].
## [br]
## * The [param attacker_player_index] carried by the signals identifies the
## player who should score. Ship-vs-ship collisions carry index 0 and score nothing.

signal score_changed(player_index: int, score: int)

const HIT_POINTS: int = 50
const KILL_POINTS: int = 150

var scores: Dictionary = { 1: 0, 2: 0 }


func _ready() -> void:
	_register_player(get_parent().get_node("Player1"))
	_register_player(get_parent().get_node("Player2"))


func add_score(player_index: int, points: int) -> void:
	if not scores.has(player_index):
		return
	scores[player_index] += points
	score_changed.emit(player_index, scores[player_index])


func _register_player(player: Player) -> void:
	player.get_node("Hurtbox").damage_received.connect(_on_damage_received)
	player.get_node("Health").died.connect(_on_died)


func _on_damage_received(_amount: int, attacker_player_index: int) -> void:
	add_score(attacker_player_index, HIT_POINTS)


func _on_died(attacker_player_index: int) -> void:
	if attacker_player_index != 0:
		add_score(attacker_player_index, KILL_POINTS)
