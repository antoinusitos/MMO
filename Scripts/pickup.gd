extends Area2D

@export var item_id : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if body.has_method("player") && MultiplayerManager.local_id == body.player_id:
		body._pickup_object(item_id)
		queue_free()
