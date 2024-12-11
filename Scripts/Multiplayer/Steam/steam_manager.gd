extends Node

var is_owned : bool = false
var steam_app_id : int = 480
var steam_id : int = 0
var steam_username : String = ""

var lobby_id = 0
var lobby_max_members = 4

func _init():
	print ("Init Steam")
	OS.set_environment("SteamAppID", str(steam_app_id))
	OS.set_environment("SteamGameID", str(steam_app_id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Steam.run_callbacks()

func initialize_steam():
	var initialize_response : Dictionary = Steam.steamInitEx()
	print ("Did Steam Initialize ?: %s" % initialize_response)
	
	if initialize_response['status'] > 0:
		print("Failed to init Steam! Shutting down. %s" % initialize_response)
		get_tree().quit()
	
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()

	print("steam_id %s" % steam_id)
	
	if is_owned == false:
		print("User does not own game!")
		get_tree().quit()
