extends MultiplayerSynchronizer

@export var input_direction : Vector2
@export var input_move_direction : Vector2
@onready var player = $".."
@export var shoot = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

	input_move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input_direction = Vector2.ZERO

func _physics_process(delta):
	input_move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input_direction = player.get_local_mouse_position()

	shoot = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
