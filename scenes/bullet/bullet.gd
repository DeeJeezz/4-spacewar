extends Area2D
class_name Bullet

@export var speed: float = 100.0
@export var ttl: float = 3.0


func _physics_process(delta: float) -> void:
	global_position += Vector2.UP.rotated(rotation) * speed * delta
	ttl -= delta
	if ttl <= 0:
		queue_free()
