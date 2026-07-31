class_name RespawnManager
extends Node
## Manages player respawns.
##
## Usage: [br]
## * Add as a child of the [GameScene] root next to [ScoreManager]. [br]
## * Each player starts with [constant INITIAL_RESPAWNS] respawns. On death the
## player is respawned at the screen periphery after [constant RESPAWN_DELAY]
## seconds. [br]
## * [signal respawns_changed] is emitted whenever a player's remaining respawn
## count changes. [br]
## * When a player runs out of respawns, [signal game_over] is emitted with the
## winner's player index and score.

signal game_over(winner_player_index: int, winner_score: int)
signal respawns_changed(player_index: int, respawns_left: int)

const INITIAL_RESPAWNS: int = 3
const RESPAWN_DELAY: float = 3.0

var respawns_left: Dictionary = { 1: INITIAL_RESPAWNS, 2: INITIAL_RESPAWNS }


func _ready() -> void:
	_register_player(get_parent().get_node("Player1"), 1)
	_register_player(get_parent().get_node("Player2"), 2)


func _register_player(player: Player, player_index: int) -> void:
	player.get_node("Health").died.connect(_on_player_died.bind(player_index))


func _on_player_died(_attacker_player_index: int, player_index: int) -> void:
	respawns_left[player_index] -= 1
	respawns_changed.emit(player_index, respawns_left[player_index])
	if respawns_left[player_index] <= 0:
		var winner_index: int = 3 - player_index
		var score_manager: ScoreManager = get_parent().get_node("ScoreManager")
		game_over.emit(winner_index, score_manager.scores[winner_index])
		return

	var player: Player = get_parent().get_node("Player%d" % player_index)
	await get_tree().create_timer(RESPAWN_DELAY).timeout
	if is_instance_valid(player):
		player.respawn(_random_periphery_position())
		var star: Star = get_parent().get_node("Star")
		star.apply_initial_radial_velocity(player)


func _random_periphery_position() -> Vector2:
	var margin: float = 20.0
	var size: Vector2 = Game.SCREEN_SIZE
	var width: float = size.x - margin * 2.0
	var height: float = size.y - margin * 2.0
	var distance: float = randf() * (width * 2.0 + height * 2.0)

	if distance < width:
		return Vector2(margin + distance, margin)
	distance -= width
	if distance < height:
		return Vector2(size.x - margin, margin + distance)
	distance -= height
	if distance < width:
		return Vector2(size.x - margin - distance, size.y - margin)
	return Vector2(margin, size.y - margin - distance)
