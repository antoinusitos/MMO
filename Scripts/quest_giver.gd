extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_enter(body):
	if body.has_method("player") && MultiplayerManager.local_id == body.player_id:
		print("player has entered")
		body._activate_interaction()


func _on_area_2d_body_exited(body):
	if body.has_method("player") && MultiplayerManager.local_id == body.player_id:
		print("player has exit")
		body._clear_interaction()
