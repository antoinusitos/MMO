extends CharacterBody2D

const SPEED = 300.0
@onready var sprite_2d = $AnimatedSprite2D
@onready var sprite_2d_2 = $Weapon

@export var direction : Vector2
@export var move_direction : Vector2

@onready var ray_cast_2d = $Weapon/RayCast2D

@export var player_id := 1:
	set(id): 
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)
	
func player():
	pass
	
func _ready():	
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false

func _apply_animations(delta):
	var weapon_rot = Vector2.RIGHT.dot(direction.normalized())
	
	if direction.x > 0:
		sprite_2d.flip_h = false
		sprite_2d_2.flip_h = false
		sprite_2d_2.z_index = 0
		
		if direction.y > 0:
			sprite_2d_2.global_rotation_degrees =  (1 -weapon_rot) * 90
		else:
			sprite_2d_2.global_rotation_degrees = (1 -weapon_rot) * -90
		
	elif direction.x < 0:
		sprite_2d.flip_h = true
		sprite_2d_2.flip_h = true
		sprite_2d_2.z_index = -1
		
		sprite_2d_2.global_rotation_degrees = 90 
		
		if direction.y > 0:
			sprite_2d_2.global_rotation_degrees =  (1 -weapon_rot) * 90 - 180
		else:
			sprite_2d_2.global_rotation_degrees = (1 -weapon_rot) * -90 - 180
	
		
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
	
	if %InputSynchronizer.shoot:
		%InputSynchronizer.shoot = false
		var hit = ray_cast_2d.get_collider()
		if hit && hit.has_method("take_damage"):
			print(hit.name)
			hit.take_damage()
		else:
			print("no hit")

func _physics_process(delta):
	if multiplayer.is_server():
		_apply_movement_from_input(delta)
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)
