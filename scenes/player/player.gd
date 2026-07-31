class_name Player
extends CharacterBody2D
## Base player class
##
## Usage: [br]
## * Set [param player_index] to "1" or "2" to specify the player's index. Player 1 is the left player,
## Player 2 is the right player. [br]
## * Set [param thrust_strength] to adjust the player's thrust strength. [br]
## * Set [param bullet_scene] to the player's bullet scene. [br]
## * Set [param shoot_cooldown] to adjust the player's shoot cooldown.

@export var thrust_strength: float = 50.0
@export var rotation_speed: float = 2.0
@export var bullet_scene: PackedScene
@export var shoot_cooldown: float = 0.5

@export var bullet_spawn_point: Marker2D

@export_enum("LEFT:1", "RIGHT:2") var player_index: int

var _thrust_direction: Vector2 = Vector2.ZERO

var _can_shoot: bool = true

var _exhaust_tween: Tween

@onready var _exhaust: AnimatedSprite2D = $Exhaust
@onready var _health: Health = $Health
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _ship_sprite: Sprite2D = $Sprite2D
@onready var _explosion: AnimatedSprite2D = $Explosion


func _ready() -> void:
	_health.died.connect(_on_died)


func _process(delta: float) -> void:
	handle_input(delta)


func _physics_process(delta: float) -> void:
	velocity += _thrust_direction * thrust_strength * delta
	velocity = velocity.limit_length(50)

	move_and_slide()


func handle_input(delta: float) -> void:
	var rotation_direction: float = Input.get_axis(
		&"p%d_rotate_left" % player_index,
		&"p%d_rotate_right" % player_index,
	)
	rotation += rotation_direction * delta * rotation_speed

	if Input.is_action_pressed(&"p%d_thrust" % player_index):
		_thrust_direction = Vector2.UP.rotated(rotation)
		if not _exhaust.is_playing():
			_exhaust.play(&"idle")
		_fade_exhaust(1.0)
	else:
		_thrust_direction = Vector2.ZERO
		_fade_exhaust(0.0)

	if Input.is_action_pressed(&"p%d_shoot" % player_index) and _can_shoot:
		fire_bullet()
		_can_shoot = false
		get_tree().create_timer(shoot_cooldown).timeout.connect(
			func() -> void:
				_can_shoot = true,
		)


func fire_bullet() -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = bullet_spawn_point.global_position
	bullet.rotation = rotation
	bullet.owner_player_index = player_index


func _fade_exhaust(target_alpha: float) -> void:
	if _exhaust_tween and _exhaust_tween.is_valid():
		_exhaust_tween.kill()
	_exhaust_tween = create_tween()
	_exhaust_tween.tween_property(_exhaust, "modulate:a", target_alpha, 0.3)
	if is_zero_approx(target_alpha):
		_exhaust_tween.finished.connect(
			func():
				_exhaust.stop()
				_exhaust.modulate.a = 0.0,
		)


func _on_died(_attacker_player_index: int) -> void:
	set_process(false)
	set_physics_process(false)
	set_deferred(&"collision_layer", 0)
	set_deferred(&"collision_mask", 0)
	_hurtbox.set_deferred(&"monitoring", false)
	_ship_sprite.visible = false
	_explosion.show()
	_explosion.play(str(player_index))
	_explosion.animation_finished.connect(queue_free)
