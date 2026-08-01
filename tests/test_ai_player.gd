extends Node
## Tests for the EnemyAI component that drives an AI-controlled player.

const FIXTURES: GDScript = preload("res://tests/fixtures.gd")


func test_ai_resolves_the_enemy_player(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	framework.check_equal(ai._get_enemy(), duel.player1, "AI targets the other player")
	_cleanup(duel)


func test_ai_rotates_towards_the_enemy(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(100, 0)

	ai._process(0.016)

	framework.check_true(duel.player2.rotation > 0.0, "ship rotates toward the enemy")
	framework.check_almost_equal(
		duel.player2._thrust_direction.length(),
		0.0,
		0.001,
		"no thrust inside the comfortable band",
	)
	_cleanup(duel)


func test_ai_fires_when_aimed_at_enemy(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(0, -100)
	ai.accuracy = 1.0
	ai.aim_error = 0.0

	ai._process(0.016)

	var bullets := _bullets_in(duel.root)
	framework.check_equal(bullets.size(), 1, "fires when aimed at the enemy")
	framework.check_equal(bullets[0].owner_player_index, 2, "bullet belongs to the AI player")
	_cleanup(duel)


func test_ai_does_not_fire_when_not_aimed(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(0, 100)

	ai._process(0.016)

	framework.check_equal(_bullets_in(duel.root).size(), 0, "does not fire while facing away")
	_cleanup(duel)


func test_ai_approaches_a_distant_enemy(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(300, 0)

	ai._process(0.016)

	framework.check_true(
		duel.player2._thrust_direction.length() > 0.0,
		"thrusts toward a distant enemy",
	)
	framework.check_true(duel.player2.rotation > 0.0, "turns toward the distant enemy")
	_cleanup(duel)


func test_ai_retreats_when_enemy_is_close(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(0, -50)

	ai._process(0.016)

	framework.check_true(
		duel.player2._thrust_direction.length() > 0.0,
		"thrusts to escape a close enemy",
	)
	framework.check_true(duel.player2.rotation > 0.0, "turns away from the close enemy")
	_cleanup(duel)


func test_ai_weaves_in_the_combat_band(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	ai.strafe_interval = 0.02
	ai.strafe_duration = 0.02
	ai._phase_timer = ai.strafe_interval
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(100, 0)

	for i in 30:
		ai._process(0.016)

	framework.check_true(ai._weaving, "alternates into the weave phase in the combat band")
	framework.check_true(duel.player2._thrust_direction.length() > 0.0, "thrusts while weaving")
	framework.check_almost_equal(
		ai._heading.dot(Vector2.RIGHT),
		0.0,
		0.001,
		"weave runs perpendicular to the enemy",
	)
	_cleanup(duel)


func test_ai_dodges_an_incoming_bullet(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(0, -100)
	var bullet: Bullet = FIXTURES.make_bullet(1)
	bullet.global_position = Vector2(-60, 0)
	bullet.rotation = PI / 2.0
	duel.root.add_child(bullet)

	ai._process(0.016)

	framework.check_true(ai._dodge_timer > 0.0, "dodging state activates for a threatening bullet")
	framework.check_true(duel.player2._thrust_direction.length() > 0.0, "thrusts while dodging")
	framework.check_almost_equal(
		ai._dodge_heading.dot(Vector2.RIGHT),
		0.0,
		0.001,
		"dodge runs perpendicular to the bullet",
	)
	framework.check_equal(_bullets_in(duel.root).size(), 1, "does not fire while dodging")
	_cleanup(duel)


func test_ai_does_not_dodge_a_close_bullet(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(0, -100)
	var bullet: Bullet = FIXTURES.make_bullet(1)
	bullet.global_position = Vector2(-15, 0)
	bullet.rotation = PI / 2.0
	duel.root.add_child(bullet)

	ai._process(0.016)

	framework.check_equal(ai._dodge_timer, 0.0, "ignores a bullet too close to react to")
	_cleanup(duel)


func test_ai_keeps_stale_heading_until_next_think(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	ai.think_interval = 0.15
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(100, 0)

	ai._process(0.016)
	var rotation_after_first_think: float = duel.player2.rotation
	framework.check_true(
		rotation_after_first_think > 0.0,
		"steers toward the initial enemy position",
	)

	duel.player1.global_position = Vector2(0, -100)
	ai._process(0.016)
	framework.check_true(
		duel.player2.rotation > rotation_after_first_think,
		"keeps the stale heading until the next think tick",
	)

	for i in 60:
		ai._process(0.016)

	framework.check_almost_equal(
		duel.player2.rotation,
		0.0,
		0.05,
		"re-plans and levels toward the new enemy position",
	)
	_cleanup(duel)


func test_ai_accuracy_blocks_shots(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(0, -100)
	ai.accuracy = 0.0

	ai._process(0.016)

	framework.check_equal(_bullets_in(duel.root).size(), 0, "never fires at zero accuracy")
	_cleanup(duel)


func test_ai_stands_down_without_an_enemy(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.get_parent().remove_child(duel.player1)

	ai._process(0.016)

	framework.check_equal(
		duel.player2._thrust_direction,
		Vector2.ZERO,
		"no thrust without an enemy",
	)
	framework.check_equal(_bullets_in(duel.root).size(), 0, "no shots without an enemy")
	_cleanup(duel)


func test_ai_stops_when_its_player_is_dead(framework: RefCounted) -> void:
	var duel := _make_ai_duel()
	var ai: EnemyAI = duel.ai
	duel.player2.global_position = Vector2.ZERO
	duel.player2.rotation = 0.0
	duel.player1.global_position = Vector2(0, -100)
	duel.player2.get_node("Health").kill()

	ai._process(0.016)

	framework.check_equal(duel.player2._thrust_direction, Vector2.ZERO, "no thrust while dead")
	framework.check_equal(_bullets_in(duel.root).size(), 0, "no shots while dead")
	_cleanup(duel)


func _make_ai_duel() -> Dictionary:
	var root := Node.new()
	root.name = "AIDuelFixture"
	var player1: Player = FIXTURES.make_player(1)
	player1.name = "Player1"
	root.add_child(player1)
	var player2: Player = FIXTURES.make_player(2)
	player2.name = "Player2"
	player2.is_ai = true
	root.add_child(player2)
	add_child(root)
	var ai: EnemyAI = player2.get_node("EnemyAI")
	ai.think_interval = 0.001
	return { "root": root, "player1": player1, "player2": player2, "ai": ai }


func _bullets_in(root: Node) -> Array[Bullet]:
	var bullets: Array[Bullet] = []
	for child in root.get_children():
		if child is Bullet:
			bullets.append(child)
	return bullets


func _cleanup(duel: Dictionary) -> void:
	duel.root.queue_free()
