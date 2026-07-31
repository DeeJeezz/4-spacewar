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


func test_ship_collision_kills_both_from_single_detection(framework: RefCounted) -> void:
	var player1: Player = Fixtures.make_player(1)
	player1.name = "Player1"
	player1.collision_layer = 1
	player1.collision_mask = 0
	add_child(player1)
	var player2: Player = Fixtures.make_player(2)
	player2.name = "Player2"
	player2.collision_layer = 1
	player2.collision_mask = 0
	add_child(player2)
	player1.get_node("Hurtbox").body_entered.emit(player2)
	framework.check_true(player1.get_node("Health").is_dead, "detecting player dies")
	framework.check_true(player2.get_node("Health").is_dead, "collided player dies too")


func test_ship_collision_kills_both_players(framework: RefCounted) -> void:
	var player1: Player = Fixtures.make_player(1)
	player1.name = "Player1"
	player1.collision_layer = 1
	player1.collision_mask = 0
	add_child(player1)
	var player2: Player = Fixtures.make_player(2)
	player2.name = "Player2"
	player2.collision_layer = 1
	player2.collision_mask = 0
	add_child(player2)
	var test_position: Vector2 = Vector2(321, 123)
	player1.global_position = test_position
	player2.global_position = test_position
	for _i in 5:
		await get_tree().physics_frame
	framework.check_true(player1.get_node("Health").is_dead, "Player 1 dies on ship collision")
	framework.check_true(player2.get_node("Health").is_dead, "Player 2 dies on ship collision")
	framework.check_true(player1.get_node("Explosion").visible, "Player 1 explosion visible")
	framework.check_true(player2.get_node("Explosion").visible, "Player 2 explosion visible")


func test_ship_collision_kills_both_in_game_scene_mixed_layers(framework: RefCounted) -> void:
	var game: Node2D = (load("res://scenes/game/game.tscn") as PackedScene).instantiate()
	add_child(game)
	var player1: Player = game.get_node("Player1")
	var player2: Player = game.get_node("Player2")
	player2.collision_layer = 2
	var test_position: Vector2 = Vector2(321, 123)
	player1.global_position = test_position
	player2.global_position = test_position
	for _i in 5:
		await get_tree().physics_frame
	framework.check_true(
		player1.get_node("Health").is_dead,
		"Player 1 dies on ship collision with mixed layers",
	)
	framework.check_true(
		player2.get_node("Health").is_dead,
		"Player 2 dies on ship collision with mixed layers",
	)
	framework.check_true(
		player1.get_node("Explosion").visible,
		"Player 1 explosion visible with mixed layers",
	)
	framework.check_true(
		player2.get_node("Explosion").visible,
		"Player 2 explosion visible with mixed layers",
	)


func test_respawn_restores_collision(framework: RefCounted) -> void:
	var player: Player = Fixtures.make_player(1)
	player.collision_layer = 2
	player.collision_mask = 4
	add_child(player)
	player.get_node("Health").kill()
	await get_tree().process_frame
	framework.check_equal(player.collision_layer, 0, "collision layer cleared on death")
	framework.check_equal(player.collision_mask, 0, "collision mask cleared on death")
	player.respawn(Vector2(100, 100))
	framework.check_equal(player.collision_layer, 2, "collision layer restored on respawn")
	framework.check_equal(player.collision_mask, 4, "collision mask restored on respawn")


func _make_hurtbox() -> Hurtbox:
	var player: Player = Fixtures.make_player(1)
	add_child(player)
	return player.get_node("Hurtbox")
