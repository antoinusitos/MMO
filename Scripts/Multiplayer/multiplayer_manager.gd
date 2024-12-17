extends Node

var host_mode_enabled = false
var multiplayer_mode_enabled = false
var local_id = 0

@export var players = Array([], TYPE_INT, "", null)
@export var players_object = Array([], TYPE_OBJECT, "Node", null)
