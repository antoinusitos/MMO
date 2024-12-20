extends Area2D

@export var location_name : String = ""


func _on_body_entered(body):
	if body.has_method("player"):
		body.show_location(location_name)
