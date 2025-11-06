extends Node3D

var player_scene := preload("res://ball.tscn")

func _ready():
	# Preconfigure game.
	Network.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	if Network.multiplayer.is_server():
		Network.all_players_loaded.connect(start_game)

# Called only on the server.
func start_game():
	for id in Network.players.keys():
		spawn_player.rpc(id)

@rpc("authority", "reliable", "call_local")
func spawn_player(id: int):
	var player: Ball = player_scene.instantiate()
	player.current_char = Network.players[id].char
	player.name = str(id)
	add_child.call_deferred(player, true)
	# When the player enters the tree, then set the multiplayer authority because fuck you I guess
	player.tree_entered.connect(func():
			player.set_multiplayer_authority(id))
