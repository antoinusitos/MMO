extends Node

var health : int = 100
var health_max : int = 100
var radiation : int = 0
var radiation_max : int = 100
var xp : int = 0
var xp_max : int = 100
var level : int = 1

#SURVIVAL
var hunger : int = 100
var hunger_malus : int = 100
var hunger_max : int = 100
var hunger_decrease_time : float = 3.0
var hunger_decrease_current_time : float = 0.0
var thirst : int = 100
var thirst_malus : int = 100
var thirst_max : int = 100
var thirst_decrease_time : float = 3.0
var thirst_decrease_current_time : float = 0.0

var player : Node2D

func _process(delta):
	if player == null:
		return
	
	hunger_decrease_current_time += delta
	if hunger_decrease_current_time >= hunger_decrease_time:
		hunger_decrease_current_time = 0
		hunger -= 1
		UiManager.hunger_progress_bar.value = hunger
		
	thirst_decrease_current_time += delta
	if thirst_decrease_current_time >= thirst_decrease_time:
		thirst_decrease_current_time = 0
		thirst -= 1
		UiManager.thirst_progress_bar.value = thirst

func set_health(amount : int):
	health = amount
	if health < 0:
		health = 0
	elif health > health_max:
		health = health_max
	UiManager.health_progress_bar.value = health as float / health_max * 100
	if health == 0:
		print("DEATH")

func receive_XP(amount : int):
	xp += amount
	if xp >= xp_max:
		xp = xp - xp_max
		level += 1
		xp_max *= 2
	UiManager.xp_progress_bar.value = xp
	UiManager.xp_text.set_text("Level %s" % level)
