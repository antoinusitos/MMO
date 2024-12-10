extends Node2D

var lobby_id = 0

func host():
	print("Host")
	$MultiplayerHUD.hide()
	MultiplayerManager.become_host()
	
func join():
	print("Join")
	$MultiplayerHUD.hide()
	MultiplayerManager.join_host()
