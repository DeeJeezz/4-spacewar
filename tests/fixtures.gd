extends RefCounted
## Shared helpers that build test fixtures out of real project nodes.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const BULLET_SCENE: PackedScene = preload("res://scenes/bullet/bullet.tscn")
const STAR_SCRIPT: GDScript = preload("res://scenes/game/star.gd")
const SCORE_MANAGER_SCRIPT: GDScript = preload("res://scenes/game/score_manager.gd")
const RESPAWN_MANAGER_SCRIPT: GDScript = preload("res://scenes/game/respawn_manager.gd")


static func make_player(player_index: int) -> Player:
	var player: Player = PLAYER_SCENE.instantiate()
	player.player_index = player_index
	return player


static func make_bullet(owner_player_index: int) -> Bullet:
	var bullet: Bullet = BULLET_SCENE.instantiate()
	bullet.owner_player_index = owner_player_index
	return bullet


static func make_player_with_health() -> Node:
	return make_player(1)


static func make_game_root() -> Node:
	var root := Node.new()
	root.name = "GameFixture"
	var player1: Player = make_player(1)
	player1.name = "Player1"
	root.add_child(player1)
	var player2: Player = make_player(2)
	player2.name = "Player2"
	root.add_child(player2)
	var star: Star = STAR_SCRIPT.new()
	star.name = "Star"
	root.add_child(star)
	var score_manager: ScoreManager = SCORE_MANAGER_SCRIPT.new()
	score_manager.name = "ScoreManager"
	root.add_child(score_manager)
	var respawn_manager: RespawnManager = RESPAWN_MANAGER_SCRIPT.new()
	respawn_manager.name = "RespawnManager"
	root.add_child(respawn_manager)
	return root
