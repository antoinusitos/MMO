extends Area2D

@export var rad_per_seconds : int = 1
@export var heal : bool = false
var count : float = 0

var players = Array([], TYPE_OBJECT, "Node", null)

@onready var collision_shape_2d = $CollisionShape2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var circle : CircleShape2D = collision_shape_2d.shape as CircleShape2D
	for player in players:
		var dist : float = player.global_position.distance_to(global_position)
		var steps : float = circle.radius / rad_per_seconds
		for step in range(0,rad_per_seconds,1):
			if dist <= steps + steps * step:
				if !heal:
					RadiationManager.set_radiation_to_take(rad_per_seconds - step, 1 / (rad_per_seconds as float - step))
				else:
					RadiationManager.set_radiation_to_take(-rad_per_seconds + step, 1 / (rad_per_seconds as float - step))
				break

func _on_body_entered(body):
	if body.has_method("player") && body.player_id == MultiplayerManager.local_id:
		players.push_back(body)

func _on_body_exited(body):
	if body.has_method("player") && body.player_id == MultiplayerManager.local_id:
		RadiationManager.set_radiation_to_take(0, 0)
		players.erase(body)
