class_name Hurtbox
extends Area2D
## Hurtbox for the player.

signal ship_collided

const SHIP_COLLISION_DISTANCE: float = 24.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		var player: Player = get_parent()
		if area.owner_player_index == player.player_index:
			return
		EventBus.ship_damage_received.emit(
			area.damage,
			player.player_index,
			area.owner_player_index,
		)
		area.queue_free()


func _on_body_entered(body: Node2D) -> void:
	var local_health: Health = get_parent().get_node("Health") as Health
	if local_health == null or local_health.is_dead:
		return
	if body is Player and body != get_parent() and is_instance_valid(body):
		var other_health: Health = body.get_node("Health") as Health
		if other_health == null or other_health.is_dead:
			return
		if global_position.distance_to(body.global_position) > SHIP_COLLISION_DISTANCE:
			return
		ship_collided.emit()
		other_health.kill()
