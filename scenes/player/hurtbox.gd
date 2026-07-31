class_name Hurtbox
extends Area2D
## Hurtbox for the player.

signal damage_received(amount: int)
signal ship_collided


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		var player: Player = get_parent()
		if area.owner_player_index == player.player_index:
			return
		damage_received.emit(area.damage)
		area.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body != get_parent() and is_instance_valid(body):
		ship_collided.emit()
