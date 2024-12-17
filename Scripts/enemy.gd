extends Node2D

@export var pickup : PackedScene
@export var dead : bool = false

@export var enemy_spawner : Node2D

@onready var progress_bar = $ProgressBar

var _players_spawn_node
var _drop_rate : float = 0.5
var _xp_dealt : int = 1
@export var _health : int = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		die()
	progress_bar.value = _health

@rpc
func test_spawn():
	print("test spawn")
	var pickup_inst = pickup.instantiate()
	_players_spawn_node.add_child(pickup_inst, true)
	pickup_inst.position = position

func die():
	print("die")
	queue_free()

func take_damage(sender_id, damage):
	print("multiplayer.is_server()" + str(multiplayer.is_server()))
	
	_health -= damage
	if _health > 0:
		return
		
	dead = true
	#enemy_spawner.spawn_enemy()
	var rand : float = randf()
	print(rand)
	if rand <= _drop_rate:
		if multiplayer.is_server():
			test_spawn()
		else:
			rpc_id(sender_id,"test_spawn")
		
	return true
