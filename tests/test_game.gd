extends Node
## Tests for the Game scene's ship texture assignment.

const GAME_SCENE: PackedScene = preload("res://scenes/game/game.tscn")
const SHIP_TEXTURE_BLUE: Texture2D = preload("res://assets/img/ships/player_b_m.png")
const SHIP_TEXTURE_RED: Texture2D = preload("res://assets/img/ships/player_r_m.png")


func test_empty_ship_textures_leaves_sprites_unchanged(framework: RefCounted) -> void:
	var game: GameScene = GAME_SCENE.instantiate()
	add_child(game)
	await get_tree().process_frame
	var player1_sprite: Sprite2D = game.get_node("Player1")._ship_sprite
	var player2_sprite: Sprite2D = game.get_node("Player2")._ship_sprite
	var player1_texture: Texture2D = player1_sprite.texture
	var player2_texture: Texture2D = player2_sprite.texture

	game.ship_textures = []
	game._assign_ship_textures()

	framework.check_equal(player1_sprite.texture, player1_texture, "player 1 sprite unchanged")
	framework.check_equal(player2_sprite.texture, player2_texture, "player 2 sprite unchanged")


func test_custom_ship_texture_set_assigns_distinct(framework: RefCounted) -> void:
	var game: GameScene = GAME_SCENE.instantiate()
	add_child(game)
	await get_tree().process_frame
	var synthetic_texture: Texture2D = ImageTexture.create_from_image(
		Image.create(4, 4, false, Image.FORMAT_RGBA8),
	)
	game.ship_textures = [SHIP_TEXTURE_BLUE, SHIP_TEXTURE_RED, synthetic_texture]

	game._assign_ship_textures()

	var player1_sprite: Sprite2D = game.get_node("Player1")._ship_sprite
	var player2_sprite: Sprite2D = game.get_node("Player2")._ship_sprite
	framework.check_false(
		player1_sprite.texture == player2_sprite.texture,
		"players have different ship textures",
	)
	var assigned: Array[Texture2D] = [player1_sprite.texture, player2_sprite.texture]
	for texture in assigned:
		framework.check_true(
			game.ship_textures.has(texture),
			"assigned texture comes from the configured set",
		)
