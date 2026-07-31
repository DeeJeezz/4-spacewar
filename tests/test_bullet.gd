extends Node
## Tests for the Bullet.

const Fixtures := preload("res://tests/fixtures.gd")


func test_moves_forward(framework: RefCounted) -> void:
	var bullet: Bullet = Fixtures.make_bullet(1)
	add_child(bullet)
	bullet.rotation = 0.0
	bullet._physics_process(1.0)
	framework.check_almost_equal(
		bullet.global_position.y,
		-bullet.speed,
		0.001,
		"bullet moves up when unrotated",
	)
	framework.check_almost_equal(bullet.global_position.x, 0.0, 0.001, "no sideways drift")


func test_moves_in_rotation_direction(framework: RefCounted) -> void:
	var bullet: Bullet = Fixtures.make_bullet(1)
	add_child(bullet)
	bullet.rotation = PI / 2.0
	bullet._physics_process(1.0)
	framework.check_almost_equal(
		bullet.global_position.x,
		bullet.speed,
		0.001,
		"bullet moves right when rotated",
	)
	framework.check_almost_equal(bullet.global_position.y, 0.0, 0.001, "no vertical drift")


func test_ttl_expiry(framework: RefCounted) -> void:
	var bullet: Bullet = Fixtures.make_bullet(1)
	add_child(bullet)
	bullet.ttl = 0.5
	bullet._physics_process(0.5)
	framework.check_true(bullet.is_queued_for_deletion(), "bullet frees when ttl runs out")
	framework.check_almost_equal(bullet.ttl, 0.0, 0.001, "ttl reaches zero")


func test_owner_player_index(framework: RefCounted) -> void:
	var bullet: Bullet = Fixtures.make_bullet(2)
	framework.check_equal(bullet.owner_player_index, 2, "owner index is carried by the bullet")
	bullet.free()
