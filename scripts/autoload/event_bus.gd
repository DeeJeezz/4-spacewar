extends Node
## Global event bus: decouples gameplay components via signals.
##
## Components emit domain events here instead of wiring directly to each other.
## [signal ship_damage_received] is emitted by a [Hurtbox] whenever a player ship
## takes damage from a bullet.

signal ship_damage_received(amount: int, damaged_player_index: int, attacker_player_index: int)
