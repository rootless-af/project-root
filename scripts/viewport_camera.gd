extends Camera2D

enum CameraMotion {LEFT, RIGHT, UP, DOWN, STATIC}

@export var default_speed:float = 100.0;
@export var sprint_speed: float = 400.0;
@export var zoom_strength:float = 0.05;
@export var min_zoom:float = 0.1;
@export var max_zoom:float = 2;
@export var is_sprint_toggle:bool = false
@export var zoom_speed_multiplier: float = 1.0

@export_group("Camera Bounds")
@export var use_camera_bounds: bool = true

# These are the actual playable/world boundaries.
@export var world_left: float = 0.0
@export var world_right: float = 2000.0
@export var world_top: float = 0.0
@export var world_bottom: float = 1200.0

@export_group("Camera Bounds Debug")
@export var print_camera_bounds: bool = false
@export var print_camera_position: bool = false


@export_group("DEBUG")
@export var debug_messages: bool = false;

var is_sprinting:bool = false;
var speed:float;
var can_alter_camera:bool = true;
var is_moving:bool = false;
var motion_status:CameraMotion = CameraMotion.STATIC;


# -- Planting View --
# Used by store to zoom in in the planting area
var is_in_planting_view: bool = false;
var is_entering_planting_view: bool = false;

#var previous_position: Vector2;
#var previous_zoom: Vector2;

@export_group("Planting View")
@export var planting_y: float;
@export var planting_zoom: float = 1.0;
@export var planting_transition_duration: float = 0.5;

@export_subgroup("Animation")
@export var planting_transition: Tween.TransitionType = Tween.TRANS_QUAD
@export var planting_ease: Tween.EaseType = Tween.EASE_OUT

var camera_tween: Tween

func _ready() -> void:
	speed = default_speed;


func _process(delta: float) -> void:
	
	if debug_messages:
		print("[Camera] Position: ", position);
	
	if print_camera_bounds:
		print_current_camera_bounds()
	
	
	if is_in_planting_view:
		handle_planting_camera(delta);
	else:
		handle_normal_camera(delta);
	
	MusicManager.set_camera_depth(global_position.y);
	
func handle_normal_camera(delta: float) -> void:
	if not can_alter_camera:
		return

	if not speed:
		return

	# -- Camera Movement --
	if Input.is_action_pressed("camera_left"):
		move_camera(CameraMotion.LEFT, delta)
	elif Input.is_action_pressed("camera_right"):
		move_camera(CameraMotion.RIGHT, delta)

	if Input.is_action_pressed("camera_up"):
		move_camera(CameraMotion.UP, delta)
	elif Input.is_action_pressed("camera_down"):
		move_camera(CameraMotion.DOWN, delta)

	# -- Sprint --
	if not is_sprint_toggle:
		if Input.is_action_pressed("sprint"):
			speed = sprint_speed
		elif Input.is_action_just_released("sprint"):
			speed = default_speed
	else:
		if Input.is_action_just_pressed("sprint"):
			if is_sprinting:
				speed = default_speed
				is_sprinting = false
			else:
				speed = sprint_speed
				is_sprinting = true

	# -- Zoom --
	if zoom_strength:
		if Input.is_action_pressed("camera_zoom_in"):
			zoom_camera(zoom_strength)

		elif Input.is_action_pressed("camera_zoom_out"):
			zoom_camera(-zoom_strength)

	clamp_camera_position()

func handle_planting_camera(delta: float) -> void:
	if is_entering_planting_view:
		return

	var current_speed := speed * (1.0 / zoom.x) * zoom_speed_multiplier

	if Input.is_action_pressed("camera_left"):
		global_position.x -= current_speed * delta

	elif Input.is_action_pressed("camera_right"):
		global_position.x += current_speed * delta

	global_position.y = planting_y

	zoom = Vector2(planting_zoom, planting_zoom)

	clamp_camera_position()

func _unhandled_input(event: InputEvent) -> void:
	if not can_alter_camera:
		return

	if is_in_planting_view or is_entering_planting_view:
		return

	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				zoom_camera(zoom_strength)

			MOUSE_BUTTON_WHEEL_DOWN:
				zoom_camera(-zoom_strength)


func zoom_camera(amount: float) -> void:
	var new_zoom := zoom.x + amount
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)

	zoom = Vector2(new_zoom, new_zoom)
	
	clamp_camera_position()

func move_camera(motion: CameraMotion, delta: float) -> void:
	is_moving = true

	var current_speed := speed * (1.0 / zoom.x) * zoom_speed_multiplier
	var movement := Vector2.ZERO

	match motion:
		CameraMotion.LEFT:
			movement.x = -current_speed * delta

		CameraMotion.RIGHT:
			movement.x = current_speed * delta

		CameraMotion.UP:
			movement.y = -current_speed * delta

		CameraMotion.DOWN:
			movement.y = current_speed * delta

	var target_position := global_position + movement

	if use_camera_bounds:
		var half_size := get_camera_half_size()

		var min_x := world_left + half_size.x
		var max_x := world_right - half_size.x

		var min_y := world_top + half_size.y
		var max_y := world_bottom - half_size.y

		if min_x > max_x:
			target_position.x = (world_left + world_right) / 2.0
		else:
			target_position.x = clamp(target_position.x, min_x, max_x)

		if min_y > max_y:
			target_position.y = (world_top + world_bottom) / 2.0
		else:
			target_position.y = clamp(target_position.y, min_y, max_y)

	global_position = target_position

func enter_planting_view() -> void:
	if is_in_planting_view:
		return
	
	is_in_planting_view = true
	is_entering_planting_view = true;
	
	if camera_tween:
		camera_tween.kill();
	
	# Remember current camera state.
	#previous_position = global_position;
	#previous_zoom = zoom;
	
	var target_position := Vector2(
		global_position.x,
		planting_y
	);
	
	var target_zoom := Vector2(
		planting_zoom,
		planting_zoom
	);
	
	camera_tween = create_tween();
	camera_tween.set_parallel(true);
	camera_tween.set_trans(planting_transition);
	camera_tween.set_ease(planting_ease);

	camera_tween.tween_property(
		self,
		"global_position",
		target_position,
		planting_transition_duration
	);

	camera_tween.tween_property(
		self,
		"zoom",
		target_zoom,
		planting_transition_duration
	);
	
	camera_tween.finished.connect(_on_planting_transition_finished);

func _on_planting_transition_finished() -> void:
	is_entering_planting_view = false;	

func exit_planting_view() -> void:
	if not is_in_planting_view:
		return;
	
	is_in_planting_view = false;
	is_entering_planting_view = false;
	
	if camera_tween:
		camera_tween.kill();
	
	#animate_camera_to(
	#	previous_position,
	#	previous_zoom
	#);

func animate_camera_to(
	target_position: Vector2,
	target_zoom: Vector2
) -> void:
	if camera_tween:
		camera_tween.kill();
	
	camera_tween = create_tween();
	camera_tween.set_parallel(true);
	camera_tween.set_trans(planting_transition);
	camera_tween.set_ease(planting_ease);
	
	camera_tween.tween_property(
		self,
		"global_position",
		target_position,
		planting_transition_duration
	);
	
	camera_tween.tween_property(
		self,
		"zoom",
		target_zoom,
		planting_transition_duration
	);

func get_camera_half_size() -> Vector2:
	return get_viewport_rect().size / (2.0 * zoom)


func get_camera_position_limits() -> Rect2:
	var half_size := get_camera_half_size()

	var min_x := world_left + half_size.x
	var max_x := world_right - half_size.x

	var min_y := world_top + half_size.y
	var max_y := world_bottom - half_size.y

	return Rect2(
		min_x,
		min_y,
		max_x - min_x,
		max_y - min_y
	)

func clamp_camera_position() -> void:
	if not use_camera_bounds:
		return

	var half_size := get_camera_half_size()

	var min_x := world_left + half_size.x
	var max_x := world_right - half_size.x

	var min_y := world_top + half_size.y
	var max_y := world_bottom - half_size.y

	if min_x > max_x:
		global_position.x = (world_left + world_right) / 2.0
	else:
		global_position.x = clamp(global_position.x, min_x, max_x)

	if min_y > max_y:
		global_position.y = (world_top + world_bottom) / 2.0
	else:
		global_position.y = clamp(global_position.y, min_y, max_y)

func print_current_camera_bounds() -> void:
	var half_size := get_camera_half_size()

	print("========== CAMERA BOUNDS ==========")
	print("Camera position: ", global_position)
	print("Camera zoom: ", zoom.x)
	print("Visible half-size: ", half_size)

	print("World Left:   ", world_left)
	print("World Right:  ", world_right)
	print("World Top:    ", world_top)
	print("World Bottom: ", world_bottom)

	print("--- Camera center limits ---")
	print("Min X: ", world_left + half_size.x)
	print("Max X: ", world_right - half_size.x)
	print("Min Y: ", world_top + half_size.y)
	print("Max Y: ", world_bottom - half_size.y)
	print("===================================")
