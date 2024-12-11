extends Node2D

@export var pickup : PackedScene
@export var dead : bool = false

var _players_spawn_node

# Called when the node enters the scene tree for the first time.
func _ready():
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		die()
	pass

@rpc
func test_spawn():
	print("test spawn")
	var pickup_inst = pickup.instantiate()
	_players_spawn_node.add_child(pickup_inst, true)
	pickup_inst.position = position

func die():
	print("die")
	#test_spawn()
	queue_free()

func take_damage(sender_id):
	dead = true
	if multiplayer.is_server():
		test_spawn()
	else:
		rpc_id(sender_id,"test_spawn")
