extends Camera3D

@export var mouse_sensitivity: float = 0.2
@export var move_speed: float = 5.0
@export var shift_multiplier: float = 2.0

var rotation_x: float = 0.0
var rotation_y: float = 0.0
var move_mode: bool = false  # Toggle for camera movement mode

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Start with normal mode

func _input(event):
	# Toggle between modes (press TAB to switch)
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		move_mode = !move_mode
		if move_mode:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Lock mouse for camera
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Free mouse for UI

	# Mouse Look (Only when in move mode)
	if move_mode and event is InputEventMouseMotion:
		rotation_y -= event.relative.x * mouse_sensitivity * 0.01
		rotation_x -= event.relative.y * mouse_sensitivity * 0.01
		rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))

		rotation_degrees = Vector3(rad_to_deg(rotation_x), rad_to_deg(rotation_y), 0)

func _process(delta):
	if not move_mode:
		return  # Skip movement when not in camera mode

	var move_dir = Vector3.ZERO
	var speed = move_speed

	if Input.is_action_pressed("shift"):
		speed *= shift_multiplier

	# Move with WASD
	if Input.is_action_pressed("cUp"):
		move_dir += -transform.basis.z
	if Input.is_action_pressed("cDown"):
		move_dir += transform.basis.z
	if Input.is_action_pressed("cLeft"):
		move_dir += -transform.basis.x
	if Input.is_action_pressed("cRight"):
		move_dir += transform.basis.x
	if Input.is_action_pressed("cForward"):
		move_dir += transform.basis.y
	if Input.is_action_pressed("cBackward"):
		move_dir -= transform.basis.y

	if move_dir.length() > 0:
		move_dir = move_dir.normalized()
		global_translate(move_dir * speed * delta)
