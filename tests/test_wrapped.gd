extends Node
## Tests for the Wrapped screen-wrap component.

const SCREEN_SIZE: Vector2 = Vector2(640, 360)


func test_wraps_all_edges(framework: RefCounted) -> void:
	Game.SCREEN_SIZE = SCREEN_SIZE
	var wrapped: Wrapped = _make_wrapped()
	var margin: float = wrapped.wrap_margin
	var body: Node2D = wrapped.get_parent()

	body.global_position = Vector2(-100, 0)
	wrapped.screen_wrap()
	framework.check_almost_equal(
		body.global_position.x,
		SCREEN_SIZE.x + margin,
		0.001,
		"wraps from left to right",
	)

	body.global_position = Vector2(SCREEN_SIZE.x + 100, 0)
	wrapped.screen_wrap()
	framework.check_almost_equal(body.global_position.x, -margin, 0.001, "wraps from right to left")

	body.global_position = Vector2(0, -100)
	wrapped.screen_wrap()
	framework.check_almost_equal(
		body.global_position.y,
		SCREEN_SIZE.y + margin,
		0.001,
		"wraps from top to bottom",
	)

	body.global_position = Vector2(0, SCREEN_SIZE.y + 100)
	wrapped.screen_wrap()
	framework.check_almost_equal(body.global_position.y, -margin, 0.001, "wraps from bottom to top")


func test_inside_unchanged(framework: RefCounted) -> void:
	Game.SCREEN_SIZE = SCREEN_SIZE
	var wrapped: Wrapped = _make_wrapped()
	var body: Node2D = wrapped.get_parent()
	var position: Vector2 = Vector2(100, 100)
	body.global_position = position
	wrapped.screen_wrap()
	framework.check_equal(body.global_position, position, "interior position is untouched")


func _make_wrapped() -> Wrapped:
	var body := Node2D.new()
	add_child(body)
	var wrapped: Wrapped = Wrapped.new()
	body.add_child(wrapped)
	return wrapped
