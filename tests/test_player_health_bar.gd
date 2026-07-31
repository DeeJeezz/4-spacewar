extends Node
## Tests for the counter-rotating health bar above each player ship.

const Fixtures := preload("res://tests/fixtures.gd")


func test_bar_starts_at_full_health(framework: RefCounted) -> void:
	var player: Player = _make_player()
	framework.check_equal(
		player._health_bar.max_value,
		player._health.max_health,
		"bar max matches health max",
	)
	framework.check_equal(player._health_bar.value, player._health.max_health, "bar starts full")


func test_bar_updates_on_damage(framework: RefCounted) -> void:
	var player: Player = _make_player()
	player._health.take_damage(1, player.player_index, 2)
	framework.check_equal(
		player._health_bar.value,
		player._health.current_health,
		"bar value tracks current health",
	)


func test_bar_resets_on_respawn(framework: RefCounted) -> void:
	var player: Player = _make_player()
	player._health.take_damage(2, player.player_index, 2)
	player.respawn(Vector2.ZERO)
	framework.check_equal(
		player._health_bar.value,
		player._health.max_health,
		"respawn refills the bar",
	)


func test_bar_stays_upright_when_ship_rotates(framework: RefCounted) -> void:
	var player: Player = _make_player()
	player.rotation = PI / 2.0
	player._process(0.016)
	framework.check_almost_equal(
		player._health_bar.rotation,
		-player.rotation,
		0.001,
		"bar counter-rotates to stay upright",
	)
	var expected_position: Vector2 = Vector2(
		-Player.HEALTH_BAR_HALF_WIDTH,
		-Player.HEALTH_BAR_OFFSET,
	).rotated(-player.rotation)
	framework.check_almost_equal(
		player._health_bar.position.x,
		expected_position.x,
		0.001,
		"bar hovers above the ship in world space (x)",
	)
	framework.check_almost_equal(
		player._health_bar.position.y,
		expected_position.y,
		0.001,
		"bar hovers above the ship in world space (y)",
	)


func test_bar_hidden_on_death_and_shown_on_respawn(framework: RefCounted) -> void:
	var player: Player = _make_player()
	player._health.kill()
	framework.check_false(player._health_bar.visible, "bar hides on death")
	player.respawn(Vector2.ZERO)
	framework.check_true(player._health_bar.visible, "bar shows again on respawn")


func _make_player() -> Player:
	var player: Player = Fixtures.make_player(1)
	add_child(player)
	return player
