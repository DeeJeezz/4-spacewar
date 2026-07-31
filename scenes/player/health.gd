class_name Health
extends Node
## Health component for the player.
##
## Usage: [br]
## * Set [param max_health] to the starting health value. [br]
## * Listens to the sibling [Hurtbox] signals: bullets deal damage, ship
## collisions kill instantly.

signal health_changed(current: int, max_health: int)
signal died(attacker_player_index: int)

@export var max_health: int = 3

var current_health: int
var is_dead: bool = false


func _ready() -> void:
	current_health = max_health
	var hurtbox: Hurtbox = get_parent().get_node("Hurtbox")
	hurtbox.damage_received.connect(take_damage)
	hurtbox.ship_collided.connect(kill)


func take_damage(amount: int, attacker_player_index: int) -> void:
	if is_dead or amount <= 0:
		return
	current_health = maxi(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		is_dead = true
		died.emit(attacker_player_index)


func kill() -> void:
	if is_dead:
		return
	current_health = 0
	is_dead = true
	health_changed.emit(current_health, max_health)
	died.emit(0)


func reset() -> void:
	current_health = max_health
	is_dead = false
	health_changed.emit(current_health, max_health)
