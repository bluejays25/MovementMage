extends CharacterBody3D

@export var speed := 5.0
@export var jump_height := 1.0
@export var fall_multiplier := 2.0
@export var max_hitpoints := 100
@export var cam_sensitivity := 10.0
@export var iceblock_scene: PackedScene

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_motion := Vector2.ZERO

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var raycast: RayCast3D = $CameraPivot/Camera3D/RayCast3D
@onready var crosshair: Control = $CenterContainer/Crosshair

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		handle_camera_rotation()
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y -= gravity * delta
		else:
			velocity.y -= gravity * delta * fall_multiplier

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(jump_height * 2 * gravity)
	
	if Input.is_action_pressed("crouch"):
		scale.y = 0.5
	else:
		scale.y = 1
	
	if Input.is_action_pressed("left_click"):
		if raycast.is_colliding():
			if not raycast.get_collider() is IceBlock:
				place_ice()
	else:
		crosshair.set_norm_line(null)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_motion = -event.relative * 0.001
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func handle_camera_rotation() ->void:
	rotate_y(mouse_motion.x * cam_sensitivity)
	camera_pivot.rotate_x(mouse_motion.y * cam_sensitivity)
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x, -90.0, 90.0
	)
	mouse_motion = Vector2.ZERO

func place_ice() -> void:
	
	var point = raycast.get_collision_point()
	var local_point = to_local(point)
	var normal = raycast.get_collision_normal()
	var up = Vector3.RIGHT if normal == Vector3.UP else Vector3.UP
	
	var line_start = camera.unproject_position(point)
	var line_end = camera.unproject_position(point + normal)
	
	#crosshair.set_norm_line([line_start, line_end])
	
	var new_iceblock = iceblock_scene.instantiate()
	new_iceblock.position = local_point
	add_child(new_iceblock)
	new_iceblock.look_at(point+normal, up)
