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
	
@export var coin : int = 0
	
func player():
	pass
	
func _ready():	
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
		MultiplayerManager.local_id = player_id
	else:
		$Camera2D.enabled = false

func _apply_animations(delta):
	sprite_2d_2.look_at(get_global_mouse_position())
	
	if direction.x > 0:
		sprite_2d.flip_h = false
		sprite_2d_2.flip_h = false
		sprite_2d_2.z_index = 0
		
	elif direction.x < 0:
		sprite_2d.flip_h = true
		sprite_2d_2.flip_h = true
		sprite_2d_2.z_index = -1

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
	
	if %InputSynchronizer.shoot:
		%InputSynchronizer.shoot = false
		var hit = ray_cast_2d.get_collider()
		if hit && hit.has_method("take_damage"):
			print(hit.name)
			hit.take_damage(player_id)
		else:
			print("no hit")

func _physics_process(delta):
	if multiplayer.is_server():
		_apply_movement_from_input(delta)
	if not multiplayer.is_server() || MultiplayerManager.host_mode_enabled:
		_apply_animations(delta)

func _add_coin():
	coin += 1

func _activate_interaction():
	$interact_image.show()

func _clear_interaction():
	$interact_image.hide()
