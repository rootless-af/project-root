extends Camera2D

enum CameraMotion {LEFT, RIGHT, UP, DOWN, STATIC}

@export var default_speed:float = 100.0;
@export var sprint_speed: float = 400.0;
@export var zoom_strength:float = 0.05;
@export var min_zoom:float = 0.1;
@export var max_zoom:float = 2;
@export var is_sprint_toggle:bool = false
@export var zoom_speed_multiplier: float = 1.0

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
	
	if is_in_planting_view:
		handle_planting_camera(delta);
	else:
		handle_normal_camera(delta);
	
	MusicManager.set_camera_depth(global_position.y);
	
func handle_normal_camera(delta) -> void:
	if not can_alter_camera:
		return;
# -- Camera Movement --
	if not speed:
		return
		
	if Input.is_action_pressed("camera_left"):
		move_camera(CameraMotion.LEFT, delta)
	elif Input.is_action_pressed("camera_right"):
		move_camera(CameraMotion.RIGHT, delta)
		
	if Input.is_action_pressed("camera_up"):
		move_camera(CameraMotion.UP, delta)
	elif Input.is_action_pressed("camera_down"):
		move_camera(CameraMotion.DOWN, delta)
	
	if not is_sprint_toggle:
		if Input.is_action_pressed("sprint"):
			speed = sprint_speed;
		elif Input.is_action_just_released("sprint"):
			speed = default_speed;
	else:
		if Input.is_action_just_pressed("sprint"):
			if is_sprinting:
				speed = default_speed;
				is_sprinting = false;
			elif not is_sprinting:
				speed = sprint_speed;
				is_sprinting = true;
	
	# -- Camera Zoom --
	if not zoom_strength:
		return
	elif Input.is_action_pressed("camera_zoom_in"):
		if zoom == Vector2(max_zoom, max_zoom):
			speed = default_speed
			return;
		elif zoom + Vector2(zoom_strength, zoom_strength) > Vector2(max_zoom, max_zoom):
			zoom = Vector2(max_zoom, max_zoom)
		else:
			zoom += Vector2(zoom_strength, zoom_strength);
	elif Input.is_action_pressed("camera_zoom_out"):
		if zoom == Vector2(min_zoom, min_zoom):
			return;
		elif zoom - Vector2(zoom_strength, zoom_strength) < Vector2(min_zoom, min_zoom):
			zoom = Vector2(min_zoom, min_zoom)
		else:
			zoom -= Vector2(zoom_strength, zoom_strength);

func handle_planting_camera(delta: float) -> void:
	if is_entering_planting_view:
		return;
	
	var current_speed := speed * (1.0 / zoom.x) * zoom_speed_multiplier

	# ONLY allow horizontal movement.
	if Input.is_action_pressed("camera_left"):
		global_position.x -= current_speed * delta

	elif Input.is_action_pressed("camera_right"):
		global_position.x += current_speed * delta

	global_position.y = planting_y

	zoom = Vector2(planting_zoom, planting_zoom)

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

func move_camera(motion:CameraMotion, delta: float):
	is_moving = true;
	var current_speed = speed * (1.0 / zoom.x) * zoom_speed_multiplier
	#print(current_speed)
	match motion:
		CameraMotion.LEFT:
			"""
				If statment is needed so that the position doesn't 
					still move in a direction while the camera is not.
			"""
			#if not (position <= Vector2(limit_left,0)): 
			position -= Vector2(current_speed * delta, 0)
		CameraMotion.RIGHT:
			#if not (position >= Vector2(limit_right, 0)):
			position += Vector2(current_speed * delta, 0)
		CameraMotion.UP:
			#if not (position <= Vector2(0, limit_top)): 
			position -= Vector2(0, current_speed * delta)
		CameraMotion.DOWN:
			#if not (position >= Vector2(0, limit_bottom)):
			position += Vector2(0, current_speed * delta)

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
