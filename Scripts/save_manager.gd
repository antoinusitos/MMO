extends Node

var player : Node2D

func save():
	print("Saving...")
	print("Level : %s" % str(player.level))
	print("Health : %s" % str(player.health))
