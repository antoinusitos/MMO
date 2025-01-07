extends Node

var lobby_id = 0

func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting Dedicated Server")
		%NetworkManager.become_host(true)

func host():
	print("Host")
	%MultiplayerHUD.hide()
	%SteamHUD.hide()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	%NetworkManager.become_host()
	
func join_as_client():
	print("Join as Client")
	join_lobby()

func use_steam():
	print("Using Steam")
	%MultiplayerHUD.hide()
	%SteamHUD.show()
	SteamManager.initialize_steam()
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	%NetworkManager.active_network_type = %NetworkManager.MULTIPLAYER_NETWORK_TYPE.STEAM

func list_steam_lobbies():
	print("List Steam Lobbies")
	%NetworkManager.list_lobbies()

func join_lobby(lobby_id = 0):
	print("Joining Lobby %s" % lobby_id)
	%MultiplayerHUD.hide()
	%SteamHUD.hide()
	%NetworkManager.join_as_client(lobby_id)

func _on_lobby_match_list(lobbies : Array):
	print("On lobby match list")
	
	for lobby_child in $SteamHUD/Panel/Lobbies/VBoxContainer.get_children():
		lobby_child.queue_free()
		
	for lobby in lobbies:
		var lobby_name : String = Steam.getLobbyData(lobby, "name")
		var lobby_mode : String = Steam.getLobbyData(lobby, "mode")
		
		if lobby_name != "":
			var lobby_button : Button = Button.new()
			lobby_button.set_text(lobby_name + "|" + lobby_mode)
			lobby_button.set_size(Vector2(100, 30))
			lobby_button.add_theme_font_size_override("font_size", 8)
			
			lobby_button.set_name("lobby_%s" % lobby)
			lobby_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			lobby_button.connect("pressed", Callable(self, "join_lobby").bind(lobby))
			
			$SteamHUD/Panel/Lobbies/VBoxContainer.add_child(lobby_button)
		
