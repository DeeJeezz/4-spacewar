class_name Hurtbox
extends Area2D
## Hurtbox for the player.


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		get_parent().queue_free()
	area.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body != get_parent() and is_instance_valid(body):
		get_parent().queue_free()
		body.queue_free()
