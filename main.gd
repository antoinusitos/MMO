extends Node2D

var lobby_id = 0

func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting Dedicated Server")
		MultiplayerManager.become_host()

func host():
	print("Host")
	$MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	
func join():
	print("Join")
	$MultiplayerHUD.hide()
	MultiplayerManager.join_host()
