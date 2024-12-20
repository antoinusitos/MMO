extends CharacterBody2D

const SPEED = 150.0
@onready var sprite_2d = $AnimatedSprite2D

@onready var canvas_layer = $CanvasLayer

@onready var reload_control = $Reload
@onready var reload_bar = $Reload/ReloadBar

@onready var health_progress_bar = $CanvasLayer/Control/HealthProgressBar
@onready var radiation_progress_bar = $CanvasLayer/Control/RadiationProgressBar
@onready var warning_rad = $CanvasLayer/Control/WarningRad
@onready var rad_label = $CanvasLayer/Control/RadLabel

@onready var quest_recap_container = $CanvasLayer/Control/QuestRecapContainer
@onready var quest_panel = $CanvasLayer/Control/QuestPanel
@onready var quest_text = $CanvasLayer/Control/QuestPanel/QuestText
@onready var all_quest_panel = $CanvasLayer/Control/AllQuestPanel
@onready var all_quest_container : VBoxContainer = $CanvasLayer/Control/AllQuestPanel/AllQuestContainer

@onready var ammo_container = $CanvasLayer/Control/AmmoUI
@onready var ammo_in_stock_text = $CanvasLayer/Control/AmmoInStockText

@export var direction : Vector2
@export var move_direction : Vector2

@onready var panel_inventory = $CanvasLayer/Control/PanelInventory
@onready var inventory_container = $CanvasLayer/Control/PanelInventory/Inventory
@export var inventory_item_ui : PackedScene
@onready var grid_container = $CanvasLayer/Control/PanelInventory/GridContainer

@onready var panel_stats = $CanvasLayer/Control/PanelStats
@onready var name_stat = $CanvasLayer/Control/PanelStats/NameStat
@onready var health_stat = $CanvasLayer/Control/PanelStats/VBoxContainer/HealthStat
@onready var rad_stat = $CanvasLayer/Control/PanelStats/VBoxContainer/RadStat
@onready var xp_stat = $CanvasLayer/Control/PanelStats/VBoxContainer/XPStat
@onready var level_stat = $CanvasLayer/Control/PanelStats/VBoxContainer/LevelStat

@onready var location_text = $CanvasLayer/Control/LocationText
var showing_location : bool = false
var showing_location_duration : float = 5
var current_showing_location_duration : float = 0

var test_network : Node

var health : int = 100
var health_max : int = 100
var radiation : int = 0
var radiation_max : int = 100
var xp : int = 0
var xp_max : int = 100
var level : int = 1
var can_shoot : bool = true
var current_fire_rate : float = 0
const quick_reload_timing : float = 0.15
var can_move : bool = true

var inventory = Array([], TYPE_DICTIONARY, "", null)
@export var current_weapon : Node2D
@export var gun : PackedScene
var gun_instantiated : Node2D
@export var ak : PackedScene
var ak_instantiated : Node2D
@export var gun_index : int = 0
@export var reloading : bool = false
@export var current_reloading : float = 0
@export var ammo_prefab = preload("res://Scenes/UI/Empty_Bullet.tscn")
@export var ammo_filled_prefab = preload("res://Scenes/UI/Filled_Bullet.tscn")
@export var ammo_in_stock : int = 200

var can_interact : bool = false
var interact_object : Node2D
var is_interacting : bool = false

var synced_players : bool = false

@export var reload_sound : AudioStream

@export var player_id := 1:
	set(id): 
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)
	
func player():
	pass
	
func _ready():
	gun_instantiated = gun.instantiate()
	gun_instantiated.current_bullet_num = gun_instantiated.magazine_size
	ak_instantiated = ak.instantiate()
	ak_instantiated.current_bullet_num = ak_instantiated.magazine_size
	current_weapon = gun_instantiated
	
	_ui_replace_ammo()
	add_child(current_weapon)
		
	MultiplayerManager.players_object.push_back(self)
	
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
		MultiplayerManager.local_id = player_id
		QuestManager.player = self
		RadiationManager.player = self
		ammo_in_stock_text.set_text("Inf.")
	else:
		$Camera2D.enabled = false
		canvas_layer.visible = false

func _ui_replace_ammo():
	for ammo in ammo_container.get_child_count():
		ammo_container.get_child(ammo).queue_free()
	
	for ammo in current_weapon.current_bullet_num:
		var ammo_inst = ammo_filled_prefab.instantiate()
		ammo_container.add_child(ammo_inst)
		
	for ammo_index in range(current_weapon.magazine_size - current_weapon.current_bullet_num - 1,-1,-1):
		var ammo_inst = ammo_prefab.instantiate()
		ammo_container.add_child(ammo_inst)
		ammo_container.move_child(ammo_inst, ammo_index)

func _ui_fill_ammo():
	for ammo_index in range(current_weapon.magazine_size - 1,-1,-1):
		ammo_container.get_child(ammo_index).queue_free()
		var ammo_inst = ammo_filled_prefab.instantiate()
		ammo_container.add_child(ammo_inst)
		ammo_container.move_child(ammo_inst, ammo_index)

func _ui_remove_ammo():
	ammo_container.get_child(current_weapon.magazine_size - current_weapon.current_bullet_num - 1).queue_free()
	var ammo_inst = ammo_prefab.instantiate()
	ammo_container.add_child(ammo_inst)
	ammo_container.move_child(ammo_inst, current_weapon.magazine_size - current_weapon.current_bullet_num - 1)

func try_to_sync():
	if not multiplayer.is_server() && not synced_players && multiplayer.get_unique_id() == player_id:
		if test_network == null:
			test_network = get_tree().root.get_node("main/TestNetwork")
		print("Trying to sync... (%s players loaded)" % str(test_network.players))
		if test_network.players.size() > 0:
			print("all players loaded, start sync...")
			synced_players = true
			for player in test_network.players:
				print("try to sync %s" % str(player))
				if player != player_id:
					get_tree().root.get_node("main/Players/" + str(player)).sync_player()

func handle_timers(delta):
	if showing_location:
		current_showing_location_duration += delta
		if current_showing_location_duration >= showing_location_duration:
			current_showing_location_duration = 0
			showing_location = false
			location_text.hide()
	
	if !can_shoot:
		current_fire_rate += delta
		if current_fire_rate >= current_weapon.fire_rate:
			current_fire_rate = 0
			can_shoot = true
			
	if reloading:
		if current_reloading >= current_weapon.reload_time / 2 - quick_reload_timing && current_reloading <= current_weapon.reload_time / 2 + quick_reload_timing:
			$Reload/InputFrame.show()
			if Input.is_action_just_pressed("reload"):
				current_reloading = current_weapon.reload_time
		else:
			$Reload/InputFrame.hide()
		
		current_reloading += delta
		if current_reloading >= current_weapon.reload_time :
			current_reloading = 0
			reloading = false
			$Reload/InputFrame.hide()
			_ui_fill_ammo()
			if current_weapon.ammo_id != -1:
				ammo_in_stock -= current_weapon.magazine_size - current_weapon.current_bullet_num
				ammo_in_stock_text.set_text(str(ammo_in_stock))
			current_weapon.current_bullet_num = current_weapon.magazine_size
			reload_control.hide()
		else:
			reload_control.show()
		reload_bar.value = current_reloading / current_weapon.reload_time * 100

func start_reload():
	reloading = true
	$AudioStreamPlayer2D.stream = reload_sound
	$AudioStreamPlayer2D.play()

func stop_reloading():
	$Reload/InputFrame.hide()
	current_reloading = 0
	reloading = false
	reload_control.hide()

func handle_input():
	if Input.is_action_just_pressed("interact") && can_interact:
		interact_object._interact(self)
		can_move = false
		is_interacting = true
		QuestManager._set_quest_panel_visibility(true)
	if Input.is_action_just_pressed("Weapon0") && gun_index != 0 && !is_interacting:
		if reloading:
			stop_reloading()
		remove_child(current_weapon)
		add_child(gun_instantiated)
		current_weapon = gun_instantiated
		gun_index = 0
		_ui_replace_ammo()
		if current_weapon.ammo_id != -1:
			ammo_in_stock_text.set_text(str(ammo_in_stock))
		else:
			ammo_in_stock_text.set_text("Inf.")
		if multiplayer.is_server():
			for player in MultiplayerManager.players:
				rpc_id(player,"client_weapon_change", 1, 0)
		else:
			rpc_id(1,"server_weapon_change", player_id, 0)
	if Input.is_action_just_pressed("Weapon1") && gun_index != 1 && !reloading && !is_interacting:
		if reloading:
			stop_reloading()
		remove_child(current_weapon)
		add_child(ak_instantiated)
		current_weapon = ak_instantiated
		gun_index = 1
		_ui_replace_ammo()
		if current_weapon.ammo_id != -1:
			ammo_in_stock_text.set_text(str(ammo_in_stock))
		else:
			ammo_in_stock_text.set_text("Inf.")
		if multiplayer.is_server():
			for player in MultiplayerManager.players:
				rpc_id(player,"client_weapon_change", 1, 1)
		else:
			rpc_id(1,"server_weapon_change", player_id, 1)
	if Input.is_action_just_pressed("reload") && current_weapon.magazine_size > current_weapon.current_bullet_num && !is_interacting:
		start_reload()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && can_shoot && not reloading && !is_interacting:
		can_shoot = false
		current_weapon.current_bullet_num -= 1
		_ui_remove_ammo()
		current_weapon.play_animation()
		if multiplayer.is_server():
			server_shoot(1)
		else:
			rpc_id(1,"server_shoot", player_id)
		if current_weapon.current_bullet_num <= 0:
			print("need to reload")
			start_reload()
	if Input.is_action_just_pressed("inventory"):
		handle_inventory()
	if Input.is_action_just_pressed("character_stats"):
		handle_character_stats()
	if Input.is_action_just_pressed("quests"):
		handle_quests()

func handle_quests():
	all_quest_panel.visible = !all_quest_panel.visible
	is_interacting = all_quest_panel.visible
	if all_quest_panel.visible:
		QuestManager.show_all_quests()

func handle_character_stats():
	panel_stats.visible = !panel_stats.visible
	is_interacting = panel_stats.visible
	if panel_stats.visible:
		name_stat.set_text("Player Name")
		health_stat.set_text("Health : " + str(health) + "/" + str(health_max))
		rad_stat.set_text("Radiation : " + str(radiation) + "/" + str(radiation_max))
		xp_stat.set_text("XP : " + str(xp) + "/" + str(xp_max))
		level_stat.set_text("Level : " + str(level))

func handle_inventory():
	panel_inventory.visible = !panel_inventory.visible
	is_interacting = panel_inventory.visible
	if panel_inventory.visible:
		grid_container
		for item in grid_container.get_children():
			item.queue_free()
		for item in inventory:
			var item_ui = inventory_item_ui.instantiate()
			item_ui.get_node("Label").set_text(str(item["item_number"]))
			item_ui.get_node("Name").set_text(item["item_name"])
			grid_container.add_child(item_ui)
			
		for text in inventory_container.get_children():
			text.queue_free()
		for item in inventory:
			var label : Label = Label.new()
			label.set_text("id : " + str(item["item_id"]) + " x " + str(item["item_number"]))
			inventory_container.add_child(label)

func _process(delta):
	try_to_sync()
	
	handle_timers(delta)
	
	if multiplayer.get_unique_id() != player_id:
		return
	
	handle_input()

func _apply_animations(delta):
	current_weapon.look_at(current_weapon.global_position + direction)
	
	if direction.x > 0:
		sprite_2d.flip_h = false
		current_weapon.scale.x = 0.5
		current_weapon.get_node("WeaponModel").z_index = 0
		
	elif direction.x < 0:
		sprite_2d.flip_h = true
		current_weapon.scale.x = -0.5
		current_weapon.get_node("WeaponModel").z_index = -1

		current_weapon.rotation_degrees += 180
		
	if move_direction.x == 0  && move_direction.y == 0:
		sprite_2d.play("idle")
	else:
		sprite_2d.play("run")

func _apply_movement_from_input(delta):
	if !can_move :
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move_direction = %InputSynchronizer.input_move_direction
	direction = %InputSynchronizer.input_direction
	if move_direction:
		velocity = move_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()

func _physics_process(delta):
	if multiplayer.is_server():
		_apply_movement_from_input(delta)
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)

@rpc("any_peer", "call_remote", "reliable")
func server_shoot(sender_id : int):
	for player in MultiplayerManager.players:
		if player != 1:
			rpc_id(player,"client_play_weapon_anim", sender_id)
		else:
			client_play_weapon_anim(sender_id)
	var hit = current_weapon.get_node("./RayCast2D").get_collider()
	if hit && hit.has_method("take_damage"):
		if hit.take_damage(sender_id, current_weapon.damage):
			if multiplayer.is_server():
				receive_XP(hit._xp_dealt)
			else:
				rpc_id(sender_id,"receive_XP", hit._xp_dealt)

func _pickup_object(item_id):
	for item in inventory:
		if item["item_id"] == item_id :
			item["item_number"] += 1
			QuestManager._on_item_picked(item_id, 1)
			return
	
	var new_item = ItemManager.get_item(item_id)
	inventory.append(new_item)
	QuestManager._on_item_picked(item_id, 1)

func _get_item_number(item_id):
	for item in inventory:
		if item["item_id"] == item_id :
			return item["item_number"]
	
	return 0

func _activate_interaction():
	$interact_image.show()
	can_interact = true

func _clear_interaction():
	$interact_image.hide()
	can_interact = false
	
@rpc
func receive_XP(amount : int):
	xp += amount
	if xp >= xp_max:
		xp = xp - xp_max
		level += 1
		xp_max *= 2
	$CanvasLayer/Control/XPProgressBar.value = xp
	$CanvasLayer/Control/XPText.set_text("Level %s" % level)

func _on_close_quest_panel_button_pressed():
	QuestManager._set_quest_panel_visibility(false)
	can_move = true
	is_interacting = false

func set_health(amount : int):
	health = amount
	if health < 0:
		health = 0
	elif health > health_max:
		health = health_max
	health_progress_bar.value = health as float / health_max * 100
	if health == 0:
		print("DEATH")

func sync_player():
	print("syncing player... %s" % str(player_id))
	on_weapon_changed()

@rpc("any_peer", "call_remote", "reliable")
func server_weapon_change(sender_id : int, weapon_index : int):
	gun_index = weapon_index
	on_weapon_changed()
	for player in MultiplayerManager.players:
		rpc_id(player,"client_weapon_change", sender_id, weapon_index)
	pass
	
@rpc("authority", "call_local", "reliable")
func client_weapon_change(sender_id : int, weapon_index : int):
	gun_index = weapon_index
	on_weapon_changed()
	pass

func on_weapon_changed():
	if gun_index == 1:
		if current_weapon != null:
			remove_child(current_weapon)
		add_child(ak_instantiated)
		current_weapon = ak_instantiated
		gun_index = 1
	else:
		if current_weapon != null:
			remove_child(current_weapon)
		add_child(gun_instantiated)
		current_weapon = gun_instantiated
		gun_index = 0

@rpc
func client_play_weapon_anim(sender_id : int):
	if sender_id == player_id:
		current_weapon.play_animation()

func show_location(location_name : String):
	location_text.show()
	location_text.set_text("Entering : %s" % location_name)
	showing_location = true
