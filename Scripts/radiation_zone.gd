extends Area2D

@export var rad_per_seconds : int = 1
@export var heal : bool = false
var count : float = 0

var players = Array([], TYPE_OBJECT, "Node", null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if count < 1:
		count += delta
	if count >= 1:
		count = 0
		for player in players:
			if !heal:
				player.add_radiation(rad_per_seconds)
			else:
				player.remove_radiation(rad_per_seconds)


func _on_body_entered(body):
	if body.has_method("player"):
		players.push_back(body)

func _on_body_exited(body):
	if body.has_method("player"):
		players.erase(body)
