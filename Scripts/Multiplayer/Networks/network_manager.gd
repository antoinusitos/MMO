extends Node

enum MULTIPLAYER_NETWORK_TYPE {ENET, STEAM}

@export var _players_spawn_node : Node2D

var active_network_type : MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET
var enet_network_scene := preload("res://Scenes/Multiplayer/Networks/enet_network.tscn")
var steam_network_scene := preload("res://Scenes/Multiplayer/Networks/steam_network.tscn")
var active_network

var want_to_be_host : bool = false
var want_to_join : bool = false

func level_loaded():
	if want_to_be_host:
		want_to_be_host = false
		become_host()
	
	if want_to_join:
		want_to_join = false
		join_as_client()

func build_multiplayer_network():
	if not active_network:
		print("Setting active_network")
		
		MultiplayerManager.multiplayer_mode_enabled = true

		match active_network_type:
			MULTIPLAYER_NETWORK_TYPE.ENET:
				print("Setting network type to ENet")
				_set_active_network(enet_network_scene)
			MULTIPLAYER_NETWORK_TYPE.STEAM:
				print("Setting network type to Steam")
				_set_active_network(steam_network_scene)
			_:
				print("No match for network type")

func _set_active_network(active_network_scene):
	var network_scene_initialized = active_network_scene.instantiate()
	active_network = network_scene_initialized
	active_network._players_spawn_node = _players_spawn_node
	add_child(active_network)

func become_host(is_dedicated_server = false):
	build_multiplayer_network()
	MultiplayerManager.host_mode_enabled = true if is_dedicated_server == false else false
	active_network.become_host()
	
func join_as_client(lobby_id = 0):
	build_multiplayer_network()
	active_network.join_as_client(lobby_id)
	
func list_lobbies():
	build_multiplayer_network()
	active_network.list_lobbies()
