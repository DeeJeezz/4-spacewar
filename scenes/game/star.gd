class_name Star
extends Area2D

@export_group("Gravity")
@export var gravity_strength: float = 500_000.0
@export var minimum_gravity_distance: float = 100.0

var _targets: Array[Player]


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	for target in _targets:
		if not is_instance_valid(target):
			continue

		var offset: Vector2 = get_wrapped_offset(target.global_position, global_position)
		var distance_squared: float = offset.length_squared()

		var minimum_squared: float = minimum_gravity_distance * minimum_gravity_distance
		distance_squared = maxf(distance_squared, minimum_squared)

		var acceleration: float = gravity_strength / distance_squared
		target.velocity += offset.normalized() * acceleration * delta


func get_wrapped_offset(from: Vector2, to: Vector2) -> Vector2:
	var size: Vector2 = get_viewport_rect().size
	var offset: Vector2 = to - from

	if offset.x > size.x * 0.5:
		offset.x -= size.x
	elif offset.x < -size.x * 0.5:
		offset.x += size.x

	if offset.y > size.y * 0.5:
		offset.y -= size.y
	elif offset.y < -size.y * 0.5:
		offset.y += size.y

	return offset


func apply_initial_radial_velocity(body: Player) -> void:
	var radial: Vector2 = body.global_position - global_position
	var radius: float = radial.length()

	if radius > 0.0:
		var tangent: Vector2 = radial.normalized().rotated(PI / 2.0)
		var orbital_speed: float = sqrt(gravity_strength / radius)
		body.velocity = tangent * orbital_speed


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body not in _targets:
		_targets.append(body)
		apply_initial_radial_velocity(body)
