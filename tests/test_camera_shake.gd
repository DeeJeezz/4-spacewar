extends Node
## Tests for the ShakingCamera screen-shake effect.

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")


func test_camera_centers_on_screen(framework: RefCounted) -> void:
	var game: GameScene = await _make_game()
	var camera: ShakingCamera = game.get_node("Camera")
	framework.check_equal(
		camera.global_position,
		Game.SCREEN_SIZE / 2.0,
		"camera sits at the screen center",
	)


func test_damage_starts_shake(framework: RefCounted) -> void:
	var game: GameScene = await _make_game()
	var camera: ShakingCamera = game.get_node("Camera")

	EventBus.ship_damage_received.emit(1, 1, 2)

	framework.check_true(camera._current_intensity > 0.0, "hit builds shake intensity")
	framework.check_true(camera.is_processing(), "camera processes while shaking")
	camera._process(1.0 / camera.shake_frequency)
	framework.check_not_equal(camera.offset, Vector2.ZERO, "offset jitters while shaking")


func test_intensity_capped_at_shake_intensity(framework: RefCounted) -> void:
	var game: GameScene = await _make_game()
	var camera: ShakingCamera = game.get_node("Camera")

	EventBus.ship_damage_received.emit(10, 1, 2)

	framework.check_almost_equal(
		camera._current_intensity,
		camera.shake_intensity,
		0.001,
		"intensity never exceeds shake_intensity",
	)


func test_shake_decays_and_resets(framework: RefCounted) -> void:
	var game: GameScene = await _make_game()
	var camera: ShakingCamera = game.get_node("Camera")

	EventBus.ship_damage_received.emit(1, 1, 2)
	camera._process(1.0 / camera.shake_frequency)
	framework.check_true(camera._current_intensity > 0.0, "shake is active after a hit")

	camera._process(camera._current_intensity / camera.shake_decay)

	framework.check_equal(camera._current_intensity, 0.0, "intensity decays to zero")
	framework.check_equal(camera.offset, Vector2.ZERO, "offset resets when shake ends")
	framework.check_false(camera.is_processing(), "camera stops processing when idle")


func _make_game() -> GameScene:
	var game: GameScene = GAME_SCENE.instantiate()
	add_child(game)
	await get_tree().process_frame
	return game
