extends Node
## Tests for the Hurtbox component.

const Fixtures := preload("res://tests/fixtures.gd")


func test_enemy_bullet_damages(framework: RefCounted) -> void:
	var hurtbox: Hurtbox = _make_hurtbox()
	var hits: Array = []
	EventBus.ship_damage_received.connect(
		func(amount: int, _damaged: int, attacker: int) -> void:
			hits.append([amount, attacker]),
	)
	var bullet: Bullet = Fixtures.make_bullet(2)
	bullet.global_position = Vector2(10000, 10000)
	add_child(bullet)
	hurtbox.area_entered.emit(bullet)
	framework.check_equal(hits, [[bullet.damage, 2]], "enemy bullet reports its damage and owner")
	framework.check_true(bullet.is_queued_for_deletion(), "hit bullet is freed")


func test_own_bullet_ignored(framework: RefCounted) -> void:
	var hurtbox: Hurtbox = _make_hurtbox()
	var hits: Array = []
	EventBus.ship_damage_received.connect(
		func(_amount: int, _damaged: int, attacker: int) -> void:
			hits.append(attacker),
	)
	var bullet: Bullet = Fixtures.make_bullet(1)
	bullet.global_position = Vector2(10000, 10000)
	add_child(bullet)
	hurtbox.area_entered.emit(bullet)
	framework.check_equal(hits, [], "own bullet is ignored")
	framework.check_false(bullet.is_queued_for_deletion(), "own bullet is not freed")


func test_ship_collision(framework: RefCounted) -> void:
	var player: Player = Fixtures.make_player(1)
	add_child(player)
	var other: Player = Fixtures.make_player(2)
	add_child(other)
	var hurtbox: Hurtbox = player.get_node("Hurtbox")
	var collisions: Array = []
	hurtbox.ship_collided.connect(
		func() -> void:
			collisions.append(true),
	)
	hurtbox.body_entered.emit(other)
	framework.check_equal(collisions.size(), 1, "ship collision reported")
	hurtbox.body_entered.emit(player)
	framework.check_equal(collisions.size(), 1, "self collision ignored")


func _make_hurtbox() -> Hurtbox:
	var player: Player = Fixtures.make_player(1)
	add_child(player)
	return player.get_node("Hurtbox")
