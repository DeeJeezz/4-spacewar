extends Area2D
class_name Star

var _targets: Array[Player]


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_targets.append(body)


func _physics_process(delta: float) -> void:
	for target in _targets:
		target.velocity += ((global_position - target.position) + Vector2.DOWN) * delta * 0.05
