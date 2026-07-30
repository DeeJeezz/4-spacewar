class_name Player
extends CharacterBody2D

@export var player_index: StringName
@export var thrust_strength: float = 50.0
@export var bullet_scene: PackedScene
@export var shoot_cooldown: float = 0.5

var _thrust_direction: Vector2 = Vector2.ZERO

var _can_shoot: bool = true


func _process(delta: float) -> void:
	handle_input(delta)


func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	velocity += _thrust_direction * thrust_strength * delta
	velocity *= 0.99
	velocity = velocity.limit_length(50)

	move_and_slide()


func handle_input(delta: float) -> void:
	var rotation_direction: float = Input.get_axis(
		&"p%s_rotate_left" % player_index,
		&"p%s_rotate_right" % player_index,
	)
	rotate(rotation_direction * delta)

	if Input.is_action_pressed("p%s_thrust" % player_index):
		_thrust_direction = Vector2.UP.rotated(rotation)
	else:
		_thrust_direction = Vector2.ZERO

	if Input.is_action_pressed("p%s_shoot" % player_index) and _can_shoot:
		fire_bullet()
		_can_shoot = false
		get_tree().create_timer(shoot_cooldown).timeout.connect(
			func() -> void:
				_can_shoot = true,
		)


func fire_bullet() -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.rotation = rotation
