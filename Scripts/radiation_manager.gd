extends Node

var next_rad_to_take : int = 0
var step_rad_time : float = 0
var current_step_rad_time : float = 0

var last_time_rads : float = 0
var rads_warning_show = 0
var time_to_show_rads_warning : float = 3

var player : Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if last_time_rads > 0:
		if rads_warning_show >= 0.25:
			rads_warning_show = 0
			if player.warning_rad.visible:
				player.warning_rad.hide()
			else:
				player.warning_rad.show()
		rads_warning_show += delta
		last_time_rads -= delta
		if last_time_rads <= 0:
			last_time_rads = 0
			player.warning_rad.hide()
	
	if next_rad_to_take != 0:
		current_step_rad_time += delta
		if current_step_rad_time >= step_rad_time:
			current_step_rad_time = 0
			if next_rad_to_take > 0:
				add_radiation(1)
			else:
				remove_radiation(-1)

func add_radiation(amount : int):
	player.radiation += amount
	if player.radiation > player.health_max:
		player.radiation = player.health_max
	if player.health > player.health_max - player.radiation:
		player.set_health(player.health_max - player.radiation)
	player.radiation_progress_bar.value = player.radiation as float / player.radiation_max * 100
	last_time_rads = time_to_show_rads_warning

func remove_radiation(amount : int):
	player.radiation -= amount
	if player.radiation < 0:
		player.radiation = 0
	player.radiation_progress_bar.value = player.radiation as float / player.radiation_max* 100

func set_radiation_to_take(amount : int, step : float):
	next_rad_to_take = amount
	step_rad_time = step
	if amount > 0:
		player.rad_label.set_text("Rads (" + str(next_rad_to_take) + "/s)")
	else:
		player.rad_label.set_text("Rads")
