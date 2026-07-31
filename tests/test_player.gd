extends Node
## Tests for the Player ship's death/respawn behavior.

const Fixtures := preload("res://tests/fixtures.gd")


func test_exhaust_hidden_on_death(framework: RefCounted) -> void:
	var player: Player = _make_player()
	player.set_thrusting(true)
	player._process(0.016)
	player._health.kill()
	framework.check_false(player._exhaust.is_playing(), "exhaust stops playing on death")
	framework.check_almost_equal(
		player._exhaust.modulate.a,
		0.0,
		0.001,
		"exhaust alpha resets on death",
	)


func test_exhaust_stays_hidden_after_respawn(framework: RefCounted) -> void:
	var player: Player = _make_player()
	player.set_thrusting(true)
	player._process(0.016)
	player._health.kill()
	player.respawn(Vector2.ZERO)
	framework.check_false(player._exhaust.is_playing(), "exhaust not playing after respawn")
	framework.check_almost_equal(
		player._exhaust.modulate.a,
		0.0,
		0.001,
		"exhaust alpha still zero after respawn",
	)


func _make_player() -> Player:
	var player: Player = Fixtures.make_player(1)
	add_child(player)
	return player
