extends Node2D

@export var enemy_to_spawn : PackedScene

var _players_spawn_node

func _ready():
	_players_spawn_node = get_tree().get_current_scene()

func spawn_enemy():
	var spawned_enemy : Node = enemy_to_spawn.instantiate()
	_players_spawn_node.add_child(spawned_enemy)
	spawned_enemy.enemy_spawner = self
	var new_position : Vector2 = position + Vector2(randf() * $Area2D.position.x, randf() * $Area2D.position.y)
	spawned_enemy.position = new_position
