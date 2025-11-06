extends Node

signal player_connected(id: int, player_info: Dictionary)
signal player_disconnected(id: int)
signal server_disconnected
signal all_players_loaded
signal load_progress(done: int, total: int)
signal player_info_changed(id: int, new_info: Dictionary)
signal player_list_changed

const MAX_PLAYERS: int = 10

@export var GAMESTATE: STATES
@export var status: Label
@export var anim: AnimationPlayer

const JOIN_SCENE_PATH: String = "res://network/join.tscn"
const LOBBY_SCENE_PATH: String = "res://network/lobby.tscn"

enum STATES {
		WAITING_ROOM,
		ROUND,
		WIN,
		BALLS,
}
# SERVER SIDE we count total rounds won, etc
var total_runs := 0

var players := {}
var player_info := new_player_info("", Ball.C.NULL)

func new_player_info(n: String, c: Ball.C) -> Dictionary:
	return {"name": n, "char": c, "wins": 0, "laps": 0, "id": -1}

var players_loaded: int = 0

const PORT: int = 5335

var peer: ENetMultiplayerPeer

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		push_error(error_string(err))
		assert(false)
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_info.id = 1
	player_connected.emit(1, player_info)
	player_list_changed.emit()

func start_client(ip: String) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer

@rpc("call_local", "any_peer", "reliable")
func lap() -> void:
	var id := multiplayer.get_remote_sender_id()
	players[id].laps += 1
	if players[id].laps >= 3:
		players[id].wins += 1
		if multiplayer.is_server():
			load_game.rpc(LOBBY_SCENE_PATH)
	player_list_changed.emit()

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id: int):
	player_info.id = id
	_register_player.rpc_id(id, player_info)

func kick_player(id: int) -> void:
	if not multiplayer.is_server(): return
	multiplayer.multiplayer_peer.disconnect_peer(id)

@rpc("any_peer", "reliable")
func _register_player(info: Dictionary) -> void:
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = info
	player_connected.emit(new_player_id, info)
	player_list_changed.emit()

func _on_player_disconnected(id: int) -> void:
	players.erase(id)
	player_disconnected.emit(id)
	if id == multiplayer.multiplayer_peer.get_unique_id():
		get_tree().change_scene_to_file(JOIN_SCENE_PATH)
	player_list_changed.emit()


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	get_tree().change_scene_to_file(JOIN_SCENE_PATH)
	player_list_changed.emit()


func _on_connected_ok() -> void:
	var peer_id := multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	remove_multiplayer_peer()
	get_tree().change_scene_to_file(JOIN_SCENE_PATH)


func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
	get_tree().change_scene_to_file(JOIN_SCENE_PATH)

@rpc("authority", "call_local", "reliable")
func load_game(game_scene_path: String):
	get_tree().change_scene_to_file(game_scene_path)

@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	players_loaded += 1
	if multiplayer.is_server() and players_loaded >= players.size():
		all_players_loaded.emit()

	load_progress.emit(players_loaded, players.size())
	if players_loaded >= players.size():
		players_loaded = 0

@rpc("any_peer", "call_local", "reliable")
func change_player_info(new_info: Dictionary) -> void:
	var id := multiplayer.get_remote_sender_id()
	players[id] = new_info
	player_info_changed.emit(id, new_info)
	#print(players)
	player_list_changed.emit()

@rpc("any_peer", "call_local")
func display_status(s: String) -> void:
	status.text = s
	anim.stop()
	anim.play("fade")

func local_status(s: String) -> void:
	status.text = s
	anim.stop()
	anim.play("fade")
