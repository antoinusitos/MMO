extends Node

@export var damage : int = 1
@export var fire_rate : float = 0.5
@export var magazine_size : int = 10
@export var current_bullet_num : int = 10
@export var reload_time : float = 5
@export var sound : AudioStream

var animation_time : float = 0.1
var current_animation_time : float = 0
var playing_animation : bool = false
var x_pos_start : float = 0
var x_move_amount : float = 1

@onready var weapon_model = $WeaponModel

func _ready():
	x_pos_start = weapon_model.position.x

func _process(delta):
	if not playing_animation:
		return
		
	if current_animation_time < animation_time / 2:
		weapon_model.position.x -= x_move_amount
		pass
	else:
		weapon_model.position.x += x_move_amount
		pass
	
	current_animation_time += delta
	if current_animation_time >= animation_time:
		current_animation_time = 0
		playing_animation = false
		weapon_model.position.x = x_pos_start

func play_animation():
	#sound.instantiate_playback()
	current_animation_time = 0
	playing_animation = true
	weapon_model.position.x = x_pos_start
