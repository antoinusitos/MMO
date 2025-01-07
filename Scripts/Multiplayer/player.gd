extends CharacterBody2D

const SPEED = 100.0
@onready var sprite_2d = $AnimatedSprite2D

@onready var reload_control = $Reload
@onready var reload_bar = $Reload/ReloadBar

@export var direction : Vector2
@export var move_direction : Vector2

var test_network : Node

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
		UiManager.player = self
		UiManager.show_main_ui()
		UiManager.ammo_in_stock_text.set_text("Inf.")
		SaveManager.player = self
		StatManager.player = self
	else:
		$Camera2D.enabled = false

func _ui_replace_ammo():
	for ammo in UiManager.ammo_container.get_child_count():
		UiManager.ammo_container.get_child(ammo).queue_free()
	
	for ammo in current_weapon.current_bullet_num:
		var ammo_inst = ammo_filled_prefab.instantiate()
		UiManager.ammo_container.add_child(ammo_inst)
		
	for ammo_index in range(current_weapon.magazine_size - current_weapon.current_bullet_num - 1,-1,-1):
		var ammo_inst = ammo_prefab.instantiate()
		UiManager.ammo_container.add_child(ammo_inst)
		UiManager.ammo_container.move_child(ammo_inst, ammo_index)

func _ui_fill_ammo():
	for ammo_index in range(current_weapon.magazine_size - 1,-1,-1):
		UiManager.ammo_container.get_child(ammo_index).queue_free()
		var ammo_inst = ammo_filled_prefab.instantiate()
		UiManager.ammo_container.add_child(ammo_inst)
		UiManager.ammo_container.move_child(ammo_inst, ammo_index)

func _ui_remove_ammo():
	UiManager.ammo_container.get_child(current_weapon.magazine_size - current_weapon.current_bullet_num - 1).queue_free()
	var ammo_inst = ammo_prefab.instantiate()
	UiManager.ammo_container.add_child(ammo_inst)
	UiManager.ammo_container.move_child(ammo_inst, current_weapon.magazine_size - current_weapon.current_bullet_num - 1)

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
				UiManager.ammo_in_stock_text.set_text(str(ammo_in_stock))
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
			UiManager.ammo_in_stock_text.set_text(str(ammo_in_stock))
		else:
			UiManager.ammo_in_stock_text.set_text("Inf.")
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
			UiManager.ammo_in_stock_text.set_text(str(ammo_in_stock))
		else:
			UiManager.ammo_in_stock_text.set_text("Inf.")
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
	UiManager.all_quest_panel.visible = !UiManager.all_quest_panel.visible
	is_interacting = UiManager.all_quest_panel.visible
	if UiManager.all_quest_panel.visible:
		QuestManager.show_all_quests()

func handle_character_stats():
	UiManager.panel_stats.visible = !UiManager.panel_stats.visible
	is_interacting = UiManager.panel_stats.visible
	if UiManager.panel_stats.visible:
		UiManager.name_stat.set_text("Player Name")
		UiManager.health_stat.set_text("Health : " + str(StatManager.health) + "/" + str(StatManager.health_max))
		UiManager.rad_stat.set_text("Radiation : " + str(StatManager.radiation) + "/" + str(StatManager.radiation_max))
		UiManager.xp_stat.set_text("XP : " + str(StatManager.xp) + "/" + str(StatManager.xp_max))
		UiManager.level_stat.set_text("Level : " + str(StatManager.level))

func handle_inventory():
	UiManager.panel_inventory.visible = !UiManager.panel_inventory.visible
	is_interacting = UiManager.panel_inventory.visible
	if UiManager.panel_inventory.visible:
		for item in UiManager.grid_container.get_children():
			item.queue_free()
		for item in inventory:
			var item_ui = UiManager.inventory_item_ui.instantiate()
			item_ui.get_node("Label").set_text(str(item["item_number"]))
			item_ui.get_node("Name").set_text(item["item_name"])
			UiManager.grid_container.add_child(item_ui)
			
		for text in UiManager.inventory_container.get_children():
			text.queue_free()
		for item in inventory:
			var label : Label = Label.new()
			label.set_text("id : " + str(item["item_id"]) + " x " + str(item["item_number"]))
			UiManager.inventory_container.add_child(label)

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

func _pickup_object(item_id, item_quantity : int = 1):
	for item in inventory:
		if item["item_id"] == item_id :
			item["item_number"] += item_quantity
			QuestManager._on_item_picked(item_id, item_quantity)
			return
	
	var new_item = ItemManager.get_item(item_id)
	new_item["item_number"] = item_quantity
	inventory.append(new_item)
	QuestManager._on_item_picked(item_id, item_quantity)

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
	StatManager.receive_XP(amount)

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
	UiManager.show_location(location_name)
