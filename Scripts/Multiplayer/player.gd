extends CharacterBody2D

const SPEED = 300.0
@onready var sprite_2d = $AnimatedSprite2D

@export var direction : Vector2
@export var move_direction : Vector2

var health : int = 100
var xp : int = 0
var xp_max : int = 100
var level : int = 1
var can_shoot : bool = true
var current_fire_rate : float = 0

var inventory = Array([], TYPE_OBJECT, "RefCounted", Item)
@export var current_weapon : Node2D
@export var gun : PackedScene
var gun_instantiated : Node2D
@export var ak : PackedScene
var ak_instantiated : Node2D
@export var gun_index : int = 0
@export var reloading : bool = false
@export var current_reloading : float = 0

var can_interact : bool = false
var interact_object : Node2D

@export var player_id := 1:
	set(id): 
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)
	
func player():
	pass
	
func _ready():	
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
		MultiplayerManager.local_id = player_id
		gun_instantiated = gun.instantiate()
		gun_instantiated.current_bullet_num = gun_instantiated.magazine_size
		ak_instantiated = ak.instantiate()
		ak_instantiated.current_bullet_num = ak_instantiated.magazine_size
		current_weapon = gun_instantiated
		$Control/BulletsText.set_text(str(current_weapon.current_bullet_num) + " / " + str(current_weapon.magazine_size))
		add_child(current_weapon)
	else:
		$Camera2D.enabled = false

func _process(delta):
	if !can_shoot:
		current_fire_rate += delta
		if current_fire_rate >= current_weapon.fire_rate:
			current_fire_rate = 0
			can_shoot = true
	if reloading:
		current_reloading += delta
		if current_reloading >= current_weapon.reload_time :
			current_reloading = 0
			reloading = false
			current_weapon.current_bullet_num = current_weapon.magazine_size
			$Control/ReloadBar.hide()
			$Control/BulletsText.set_text(str(current_weapon.current_bullet_num) + " / " + str(current_weapon.magazine_size))
		else:
			$Control/ReloadBar.show()
		$Control/ReloadBar.value = current_reloading / current_weapon.reload_time * 100

func _apply_animations(delta):
	current_weapon.look_at(current_weapon.global_position + get_local_mouse_position())
	
	if direction.x > 0:
		sprite_2d.flip_h = false
		current_weapon.scale.x = 1
		current_weapon.get_node("WeaponModel").z_index = 0
		
	elif direction.x < 0:
		sprite_2d.flip_h = true
		current_weapon.scale.x = -1
		current_weapon.get_node("WeaponModel").z_index = -1

		current_weapon.rotation_degrees += 180
		
	if move_direction.x == 0  && move_direction.y == 0:
		sprite_2d.play("idle")
	else:
		sprite_2d.play("run")

func _apply_movement_from_input(delta):
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
	
	if %InputSynchronizer.shoot && can_shoot && not reloading:
		%InputSynchronizer.shoot = false
		can_shoot = false
		current_weapon.current_bullet_num -= 1
		$Control/BulletsText.set_text(str(current_weapon.current_bullet_num) + " / " + str(current_weapon.magazine_size))
		if current_weapon.current_bullet_num <= 0:
			print("need to reload")
			reloading = true
		var hit = current_weapon.get_node("./RayCast2D").get_collider()
		if hit && hit.has_method("take_damage"):
			print(hit.name)
			if hit.take_damage(player_id, current_weapon.damage):
				if multiplayer.is_server():
					receive_XP(hit._xp_dealt)
				else:
					rpc_id(player_id,"receive_XP", hit._xp_dealt)
		else:
			print("no hit")

func _physics_process(delta):
	if multiplayer.is_server():
		_apply_movement_from_input(delta)
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)
	if Input.is_action_just_pressed("interact") && can_interact:
		interact_object._interact(self)
	if Input.is_action_just_pressed("Weapon0") && gun_index != 0:
		remove_child(current_weapon)
		add_child(gun_instantiated)
		current_weapon = gun_instantiated
		gun_index = 0
		$Control/BulletsText.set_text(str(current_weapon.current_bullet_num) + " / " + str(current_weapon.magazine_size))
	if Input.is_action_just_pressed("Weapon1") && gun_index != 1:
		remove_child(current_weapon)
		add_child(ak_instantiated)
		current_weapon = ak_instantiated
		$Control/BulletsText.set_text(str(current_weapon.current_bullet_num) + " / " + str(current_weapon.magazine_size))
		gun_index = 1

func _pickup_object(item_id):
	for item in inventory:
		if item.item_id == item_id :
			item.item_number += 1
			return
	
	var new_item = Item.new()
	new_item.item_number = 1
	new_item.item_id = item_id
	inventory.append(new_item)

func _get_item_number(item_id):
	for item in inventory:
		if item.item_id == item_id :
			return item.item_number
	
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
	$Control/XPProgressBar.value = xp
	$Control/XPText.set_text("Level %s" % level)
