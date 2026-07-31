class_name ShakingCamera
extends Camera2D
## Camera with a screen-shake effect.
##
## Usage: [br]
## * Add as a child of the [GameScene] root next to [ScoreManager]. [br]
## * Centers itself on [constant Game.SCREEN_SIZE] and listens to
## [signal EventBus.ship_damage_received]: each hit adds shake intensity scaled
## by [param intensity_per_damage], capped at [param shake_intensity]. [br]
## * The offset jitters at [param shake_frequency] and dies down over time at
## [param shake_decay].

@export var shake_intensity: float = 12.0
@export var shake_decay: float = 8.0
@export var shake_frequency: float = 18.0
@export var intensity_per_damage: float = 4.0

var _current_intensity: float = 0.0

var _jitter_timer: float = 0.0


func _ready() -> void:
	global_position = Game.SCREEN_SIZE / 2.0
	set_process(false)
	EventBus.ship_damage_received.connect(_on_damage_received)


func _process(delta: float) -> void:
	_jitter_timer -= delta
	if _jitter_timer <= 0.0:
		_jitter_timer = 1.0 / shake_frequency
		offset = Vector2(
			randf_range(-_current_intensity, _current_intensity),
			randf_range(-_current_intensity, _current_intensity),
		)
	_current_intensity = maxf(_current_intensity - shake_decay * delta, 0.0)
	if _current_intensity == 0.0:
		offset = Vector2.ZERO
		set_process(false)


func _on_damage_received(
	amount: int,
	_damaged_player_index: int,
	_attacker_player_index: int,
) -> void:
	_current_intensity = minf(_current_intensity + amount * intensity_per_damage, shake_intensity)
	set_process(true)
