extends Node

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_scene = preload("res://Scenes/player.tscn")
var multiplayer_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var _players_spawn_node

func become_host():
	print("start host")
	
	multiplayer_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	if !OS.has_feature("dedicated_server"):
		_add_player_to_game(1)
	
func join_as_client(lobby_id):
	print("joining")
	
	multiplayer_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer

func _add_player_to_game(id : int):
	print("Player %s joined the game" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)

	_players_spawn_node.add_child(player_to_add, true)
	
	get_tree().root.get_node("main/TestNetwork").players.push_back(id)
	
	if multiplayer.is_server():
		MultiplayerManager.players.push_back(id)
		
func _del_player(id : int):
	print("Player %s left the game" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
