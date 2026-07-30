class_name Bullet
extends Area2D
## Bullet.
##
## Usage: [br]
## * Adjust [param speed] to change bullet speed. [br]
## * Adjust [param ttl] to change bullet lifetime.

@export var speed: float = 100.0
@export var ttl: float = 3.0


func _physics_process(delta: float) -> void:
	global_position += Vector2.UP.rotated(rotation) * speed * delta
	ttl -= delta
	if ttl <= 0:
		queue_free()
