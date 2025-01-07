extends Node2D

@export var pickup : PackedScene
@export var dead : bool = false

@export var enemy_spawner : Node2D

@onready var progress_bar = $ProgressBar
@onready var animated_sprite_2d = $AnimatedSprite2D

var _players_spawn_node
var _drop_rate : float = 0.5
var _xp_dealt : int = 1
@export var _health : int = 100

@export var gold_min : int = 5
@export var gold_max : int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	animated_sprite_2d.play("idle")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dead:
		die()
	progress_bar.value = _health

@rpc
func test_spawn():
	var pickup_inst = pickup.instantiate()
	_players_spawn_node.add_child(pickup_inst, true)
	pickup_inst.position = position
	StatManager.player._pickup_object(pickup_inst.item_id)
	pickup_inst.queue_free()
	var rand = randi() % gold_max + gold_min
	StatManager.player._pickup_object(2, rand)
	print("lol %s" % rand)

func die():
	queue_free()

func take_damage(sender_id, damage):
	_health -= damage
	if _health > 0:
		return
		
	dead = true
	if enemy_spawner != null:
		enemy_spawner.spawn_enemy()
	var rand : float = randf()
	print(rand)
	if rand <= _drop_rate:
		if multiplayer.is_server():
			test_spawn()
		else:
			rpc_id(sender_id,"test_spawn")
		
	return true
