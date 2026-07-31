extends Node
## Tests for the Health component.

const Fixtures := preload("res://tests/fixtures.gd")


func test_initial_state(framework: RefCounted) -> void:
	var health: Health = _make_health()
	framework.check_equal(health.current_health, health.max_health, "starts at full health")
	framework.check_false(health.is_dead, "starts alive")


func test_take_damage_reduces_health(framework: RefCounted) -> void:
	var health: Health = _make_health()
	var changed: Array = []
	health.health_changed.connect(
		func(current: int, max_health: int) -> void:
			changed.append([current, max_health]),
	)
	health.take_damage(1, 2)
	framework.check_equal(health.current_health, 2, "one damage point reduces health")
	framework.check_equal(changed, [[2, 3]], "health_changed emitted with remaining health")
	health.take_damage(2, 2)
	framework.check_equal(health.current_health, 0, "health clamps at zero")
	framework.check_true(health.is_dead, "zero health kills the player")


func test_died_emitted_once(framework: RefCounted) -> void:
	var health: Health = _make_health()
	var deaths: Array = []
	health.died.connect(
		func(attacker: int) -> void:
			deaths.append(attacker),
	)
	health.take_damage(3, 1)
	framework.check_equal(health.current_health, 0, "lethal damage zeroes health")
	framework.check_equal(deaths, [1], "died emitted once with the attacker index")
	health.take_damage(1, 2)
	framework.check_equal(deaths, [1], "no further death once already dead")
	framework.check_equal(health.current_health, 0, "no damage applied after death")


func test_non_positive_damage_ignored(framework: RefCounted) -> void:
	var health: Health = _make_health()
	health.take_damage(0, 1)
	framework.check_equal(health.current_health, health.max_health, "zero damage ignored")
	health.take_damage(-3, 1)
	framework.check_equal(health.current_health, health.max_health, "negative damage ignored")


func test_kill(framework: RefCounted) -> void:
	var health: Health = _make_health()
	var deaths: Array = []
	health.died.connect(
		func(attacker: int) -> void:
			deaths.append(attacker),
	)
	health.kill()
	framework.check_equal(health.current_health, 0, "kill zeroes health")
	framework.check_true(health.is_dead, "kill marks the player as dead")
	framework.check_equal(deaths, [0], "kill emits attacker index 0")
	health.kill()
	framework.check_equal(deaths, [0], "kill is idempotent")


func test_reset(framework: RefCounted) -> void:
	var health: Health = _make_health()
	health.take_damage(1, 1)
	health.kill()
	framework.check_true(health.is_dead, "player is dead before reset")
	var changed: Array = []
	health.health_changed.connect(
		func(current: int, max_health: int) -> void:
			changed.append(current),
	)
	health.reset()
	framework.check_equal(health.current_health, health.max_health, "reset restores full health")
	framework.check_false(health.is_dead, "reset revives the player")
	framework.check_equal(changed, [health.max_health], "reset emits health_changed")


func _make_health() -> Health:
	var fixture: Node = Fixtures.make_player_with_health()
	add_child(fixture)
	return fixture.get_node("Health")
