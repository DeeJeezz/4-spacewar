extends Node
## Tests for the Star gravity component.

const Fixtures := preload("res://tests/fixtures.gd")


func test_wrapped_offset_horizontal(framework: RefCounted) -> void:
	var star: Star = _make_star()
	var size: Vector2 = star.get_viewport_rect().size
	var half: Vector2 = size * 0.5
	framework.check_equal(
		star.get_wrapped_offset(Vector2.ZERO, Vector2(10, 0)),
		Vector2(10, 0),
		"short x offset unchanged",
	)
	var positive: Vector2 = star.get_wrapped_offset(Vector2.ZERO, Vector2(half.x + 1, 0))
	framework.check_almost_equal(
		positive.x,
		(half.x + 1) - size.x,
		0.001,
		"large positive x wraps to the other side",
	)
	var negative: Vector2 = star.get_wrapped_offset(Vector2.ZERO, Vector2(-(half.x + 1), 0))
	framework.check_almost_equal(
		negative.x,
		-(half.x + 1) + size.x,
		0.001,
		"large negative x wraps to the other side",
	)


func test_wrapped_offset_vertical(framework: RefCounted) -> void:
	var star: Star = _make_star()
	var size: Vector2 = star.get_viewport_rect().size
	var offset: Vector2 = star.get_wrapped_offset(Vector2.ZERO, Vector2(0, size.y - 1))
	framework.check_almost_equal(offset.y, -1.0, 0.001, "large y offset wraps by one screen height")


func test_apply_initial_radial_velocity(framework: RefCounted) -> void:
	var star: Star = _make_star()
	var player: Player = _make_player()
	player.global_position = Vector2(300, 0)
	player.velocity = Vector2.ZERO
	star.apply_initial_radial_velocity(player)
	var radial: Vector2 = player.global_position - star.global_position
	var expected_speed: float = sqrt(star.gravity_strength / radial.length())
	framework.check_almost_equal(
		player.velocity.length(),
		expected_speed,
		0.001,
		"orbital speed matches sqrt(g/r)",
	)
	framework.check_almost_equal(
		player.velocity.dot(radial.normalized()),
		0.0,
		0.001,
		"velocity is perpendicular to the radius",
	)


func test_body_entered_adds_target_once(framework: RefCounted) -> void:
	var star: Star = _make_star()
	var player: Player = _make_player()
	player.global_position = Vector2(300, 0)
	player.velocity = Vector2.ZERO
	star._on_body_entered(player)
	framework.check_equal(star._targets.size(), 1, "player is tracked after entering")
	framework.check_true(player.velocity.length() > 0.0, "radial velocity applied on entry")
	star._on_body_entered(player)
	framework.check_equal(star._targets.size(), 1, "player is tracked only once")
	var non_player := Node2D.new()
	star._on_body_entered(non_player)
	framework.check_equal(star._targets.size(), 1, "non-player bodies are ignored")
	non_player.free()


func test_gravity_pulls_towards_star(framework: RefCounted) -> void:
	var star: Star = _make_star()
	var player: Player = _make_player()
	player.global_position = Vector2(300, 0)
	player.velocity = Vector2.ZERO
	star._targets.append(player)
	star._physics_process(0.1)
	framework.check_true(player.velocity.x < 0.0, "gravity accelerates the player towards the star")
	framework.check_almost_equal(
		player.velocity.y,
		0.0,
		0.001,
		"no vertical acceleration on the x axis",
	)


func _make_star() -> Star:
	var star: Star = Star.new()
	add_child(star)
	return star


func _make_player() -> Player:
	var player: Player = Fixtures.make_player(1)
	add_child(player)
	return player
