extends Node
## Tests for the ScoreManager.

const Fixtures := preload("res://tests/fixtures.gd")


func test_initial_scores(framework: RefCounted) -> void:
	var score_manager: ScoreManager = _make_score_manager()
	framework.check_equal(score_manager.scores, { 1: 0, 2: 0 }, "both players start at zero")


func test_add_score(framework: RefCounted) -> void:
	var score_manager: ScoreManager = _make_score_manager()
	var changed: Array = []
	score_manager.score_changed.connect(
		func(index: int, score: int) -> void:
			changed.append([index, score]),
	)
	score_manager.add_score(1, 10)
	framework.check_equal(score_manager.scores[1], 10, "score is added for a known player")
	framework.check_equal(changed, [[1, 10]], "score_changed emitted")
	score_manager.add_score(3, 10)
	framework.check_equal(changed, [[1, 10]], "unknown player index is ignored")


func test_hit_and_kill_points(framework: RefCounted) -> void:
	var score_manager: ScoreManager = _make_score_manager()
	score_manager._on_damage_received(1, 1, 2)
	framework.check_equal(
		score_manager.scores[2],
		ScoreManager.HIT_POINTS,
		"a hit scores HIT_POINTS for the attacker",
	)
	score_manager._on_died(1)
	framework.check_equal(
		score_manager.scores[1],
		ScoreManager.KILL_POINTS,
		"a kill scores KILL_POINTS for the killer",
	)
	score_manager._on_died(0)
	framework.check_equal(
		score_manager.scores[1],
		ScoreManager.KILL_POINTS,
		"collision with attacker 0 scores nobody",
	)


func test_signal_wiring(framework: RefCounted) -> void:
	var root: Node = Fixtures.make_game_root()
	add_child(root)
	var score_manager: ScoreManager = root.get_node("ScoreManager")
	EventBus.ship_damage_received.emit(1, 2, 1)
	framework.check_equal(
		score_manager.scores[1],
		ScoreManager.HIT_POINTS,
		"a hit on player 2 registers for player 1",
	)


func _make_score_manager() -> ScoreManager:
	var root: Node = Fixtures.make_game_root()
	add_child(root)
	return root.get_node("ScoreManager")
