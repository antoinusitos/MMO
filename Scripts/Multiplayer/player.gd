extends CharacterBody2D

const SPEED = 300.0
@onready var sprite_2d = $AnimatedSprite2D
@onready var sprite_2d_2 = $Weapon

@export var direction : Vector2
@export var move_direction : Vector2

@onready var ray_cast_2d = $Weapon/RayCast2D

var health : int = 100
var xp : int = 0
var xp_max : int = 100
var level : int = 1
var can_shoot : bool = true
var fire_rate : float = 0.1
var current_fire_rate : float = 0

var inventory = Array([], TYPE_OBJECT, "RefCounted", Item) 

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
	else:
		$Camera2D.enabled = false

func _process(delta):
	if !can_shoot:
		current_fire_rate += delta
		if current_fire_rate >= fire_rate:
			current_fire_rate = 0
			can_shoot = true

func _apply_animations(delta):
	sprite_2d_2.look_at(sprite_2d_2.global_position + get_local_mouse_position())
	
	if direction.x > 0:
		sprite_2d.flip_h = false
		sprite_2d_2.flip_h = false
		sprite_2d_2.z_index = 0
		$Weapon/RayCast2D.rotation_degrees = -90
		
	elif direction.x < 0:
		sprite_2d.flip_h = true
		sprite_2d_2.flip_h = true
		sprite_2d_2.z_index = -1
		$Weapon/RayCast2D.rotation_degrees = 90

		sprite_2d_2.rotation_degrees += 180
		
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
	
	if %InputSynchronizer.shoot && can_shoot:
		%InputSynchronizer.shoot = false
		can_shoot = false
		var hit = ray_cast_2d.get_collider()
		if hit && hit.has_method("take_damage"):
			print(hit.name)
			if hit.take_damage(player_id, 10):
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

func _pickup_object(item_id):
	for item in inventory:
		if item.item_id == item_id :
			item.item_number += 1
			return
	
	var new_item = Item.new()
	new_item.item_number = 1
	new_item.item_id = item_id
	inventory.append(new_item)

func _activate_interaction():
	$interact_image.show()

func _clear_interaction():
	$interact_image.hide()
	
@rpc
func receive_XP(amount : int):
	xp += amount
	if xp >= xp_max:
		xp = xp - xp_max
		level += 1
	$Control/XPProgressBar.value = xp
	$Control/XPText.set_text("Level %s" % level)
