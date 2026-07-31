class_name EnemyAI
extends Node
## AI opponent that steers its [Player] parent against the other player.
##
## Usage: [br]
## * Add as a child of a [Player] with [member Player.is_ai] enabled — the player
## instantiates this component itself in [method Player._ready]. [br]
## * Runs in [method _process] and drives the player through its public helpers
## ([method Player.rotate_ship], [method Player.set_thrusting],
## [method Player.try_fire]). [br]
## * Behavior: keeps the ship at a comfortable distance from the enemy, aims and
## fires at it with imperfect lead and accuracy, and dodges incoming bullets it
## has time to react to. Decisions are re-planned every [member think_interval]
## seconds, so the ship keeps executing stale orders between ticks.

const TURN_DEADZONE: float = 0.02

const FIRE_JITTER_MIN: float = 0.9

const FIRE_JITTER_MAX: float = 1.3

@export_group("Combat")
@export var aim_tolerance: float = 0.15
@export var max_fire_range: float = 420.0
@export var bullet_speed: float = 100.0
@export var lead_factor: float = 0.6

@export_group("Movement")
@export var approach_range: float = 260.0
@export var retreat_range: float = 130.0
@export var retreat_hysteresis: float = 50.0

@export_group("Dodging")
@export var dodge_radius: float = 55.0
@export var dodge_horizon: float = 1.0
@export var dodge_duration: float = 0.5

@export_group("Fairness")
@export var think_interval: float = 0.15
@export var reaction_time: float = 0.25
@export var accuracy: float = 0.8
@export var aim_error: float = 0.4
@export var lead_accuracy: float = 0.7

var _player: Player

var _think_timer: float = 0.0

var _fire_lockout: float = 0.0

var _heading: Vector2 = Vector2.UP

var _thrusting: bool = false

var _dodge_timer: float = 0.0

var _dodge_sign: float = 1.0

var _dodge_heading: Vector2 = Vector2.ZERO


func _ready() -> void:
	_player = get_parent() as Player


func _process(delta: float) -> void:
	if _player == null or not _player.is_processing():
		return

	var enemy: Player = _get_enemy()
	if enemy == null:
		_player.set_thrusting(false)
		return

	_dodge_timer = maxf(_dodge_timer - delta, 0.0)
	_fire_lockout = maxf(_fire_lockout - delta, 0.0)
	_think_timer -= delta
	if _think_timer <= 0.0:
		_think_timer = think_interval
		_think(enemy)

	_steer_towards(_heading, delta)
	_player.set_thrusting(_thrusting)


func _think(enemy: Player) -> void:
	var to_enemy: Vector2 = _wrapped_delta(_player.global_position, enemy.global_position)
	var distance: float = to_enemy.length()
	var threat: Bullet = _find_threat()

	if threat != null and _dodge_timer == 0.0:
		_dodge_sign = -_dodge_sign
		_dodge_timer = dodge_duration
		_dodge_heading = Vector2.UP.rotated(threat.rotation).rotated(PI / 2.0 * _dodge_sign)

	_thrusting = false
	_heading = to_enemy.normalized()
	if _dodge_timer > 0.0:
		_heading = _dodge_heading
		_thrusting = true
	else:
		if distance > approach_range:
			_thrusting = true
		elif distance < retreat_range - retreat_hysteresis:
			_heading = -_heading
			_thrusting = true
		if distance <= max_fire_range:
			_try_fire_at(enemy, to_enemy)


func _get_enemy() -> Player:
	var parent_node: Node = _player.get_parent()
	if parent_node == null:
		return null
	var enemy: Player = parent_node.get_node_or_null("Player%d" % (3 - _player.player_index)) as Player
	if enemy == null or not is_instance_valid(enemy) or not enemy.is_processing():
		return null
	return enemy


func _find_threat() -> Bullet:
	var parent_node: Node = _player.get_parent()
	if parent_node == null:
		return null
	var closest: Bullet = null
	var closest_time: float = INF
	for child in parent_node.get_children():
		if not (child is Bullet):
			continue
		var bullet: Bullet = child as Bullet
		if bullet.owner_player_index == _player.player_index or bullet.is_queued_for_deletion():
			continue
		var direction: Vector2 = Vector2.UP.rotated(bullet.rotation)
		var relative: Vector2 = _player.global_position - bullet.global_position
		var time_to_close: float = relative.dot(direction) / bullet.speed
		if time_to_close < reaction_time or time_to_close > dodge_horizon:
			continue
		var miss_distance: float = (relative - direction * bullet.speed * time_to_close).length()
		if miss_distance <= dodge_radius and time_to_close < closest_time:
			closest = bullet
			closest_time = time_to_close
	return closest


func _try_fire_at(enemy: Player, to_enemy: Vector2) -> void:
	if _fire_lockout > 0.0:
		return
	_fire_lockout = _player.shoot_cooldown * randf_range(FIRE_JITTER_MIN, FIRE_JITTER_MAX)
	var lead: float = lead_factor * randf_range(lead_accuracy, 1.0)
	var aim_point: Vector2 = (
		enemy.global_position + enemy.velocity * to_enemy.length() / bullet_speed * lead
	)
	var to_aim: Vector2 = _wrapped_delta(_player.global_position, aim_point).normalized()
	var facing: Vector2 = Vector2.UP.rotated(_player.rotation)
	var tolerance: float = aim_tolerance * randf_range(aim_error, 1.0)
	if absf(facing.angle_to(to_aim)) <= tolerance and randf() <= accuracy:
		_player.try_fire()


func _steer_towards(direction: Vector2, delta: float) -> void:
	var facing: Vector2 = Vector2.UP.rotated(_player.rotation)
	var angle_delta: float = facing.angle_to(direction)
	if absf(angle_delta) > TURN_DEADZONE:
		_player.rotate_ship(signf(angle_delta), delta)


func _wrapped_delta(from: Vector2, to: Vector2) -> Vector2:
	var size: Vector2 = Game.SCREEN_SIZE
	var delta: Vector2 = to - from
	if delta.x > size.x * 0.5:
		delta.x -= size.x
	elif delta.x < -size.x * 0.5:
		delta.x += size.x
	if delta.y > size.y * 0.5:
		delta.y -= size.y
	elif delta.y < -size.y * 0.5:
		delta.y += size.y
	return delta
