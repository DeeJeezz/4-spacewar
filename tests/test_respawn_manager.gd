extends Node
## Tests for the RespawnManager.

const Fixtures := preload("res://tests/fixtures.gd")


func test_initial_respawns(framework: RefCounted) -> void:
	var root: Node = _make_respawn_root()
	var respawn_manager: RespawnManager = root.get_node("RespawnManager")
	framework.check_equal(
		respawn_manager.respawns_left,
		{ 1: RespawnManager.INITIAL_RESPAWNS, 2: RespawnManager.INITIAL_RESPAWNS },
		"both players start with INITIAL_RESPAWNS",
	)


func test_game_over_emitted(framework: RefCounted) -> void:
	var root: Node = _make_respawn_root()
	var respawn_manager: RespawnManager = root.get_node("RespawnManager")
	var score_manager: ScoreManager = root.get_node("ScoreManager")
	score_manager.scores[2] = 300
	respawn_manager.respawns_left[1] = 1
	var changed: Array = []
	respawn_manager.respawns_changed.connect(
		func(index: int, left: int) -> void:
			changed.append([index, left]),
	)
	var results: Array = []
	respawn_manager.game_over.connect(
		func(winner: int, score: int) -> void:
			results.append([winner, score]),
	)
	var player1_health: Health = root.get_node("Player1/Health")
	player1_health.kill()
	framework.check_equal(respawn_manager.respawns_left[1], 0, "last respawn is consumed")
	framework.check_equal(changed, [[1, 0]], "respawns_changed emitted")
	framework.check_equal(results, [[2, 300]], "game_over reports the winner and their score")


func test_full_respawn_cycle(framework: RefCounted) -> void:
	var root: Node = _make_respawn_root()
	var respawn_manager: RespawnManager = root.get_node("RespawnManager")
	var changed: Array = []
	respawn_manager.respawns_changed.connect(
		func(index: int, left: int) -> void:
			changed.append([index, left]),
	)
	var player1: Player = root.get_node("Player1")
	var player1_health: Health = root.get_node("Player1/Health")
	player1_health.kill()
	framework.check_equal(changed, [[1, 2]], "respawns decremented on death")
	framework.check_false(player1.get_node("Sprite2D").visible, "ship hidden after death")
	await get_tree().create_timer(RespawnManager.RESPAWN_DELAY + 0.1).timeout
	framework.check_true(player1.visible, "player respawned after the delay")
	framework.check_true(player1.get_node("Sprite2D").visible, "ship visible again after respawn")
	framework.check_true(player1.velocity.length() > 0.0, "orbital velocity re-applied on respawn")
	framework.check_equal(
		player1_health.current_health,
		player1_health.max_health,
		"health restored on respawn",
	)
	var margin: float = 20.0
	var size: Vector2 = Game.SCREEN_SIZE
	var position: Vector2 = player1.global_position
	var on_periphery: bool = (
		position.x <= margin + 5.0 or position.x >= size.x - margin - 5.0
		or position.y <= margin + 5.0 or position.y >= size.y - margin - 5.0
	)
	framework.check_true(on_periphery, "respawned at the screen periphery")


func _make_respawn_root() -> Node:
	var root: Node = Fixtures.make_game_root()
	add_child(root)
	return root
