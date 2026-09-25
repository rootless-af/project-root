extends Camera2D

enum CameraMotion {LEFT, RIGHT, UP, DOWN, STATIC}

@export var default_speed:float = 100.0;
@export var sprint_speed: float = 400.0;
@export var zoom_strength:float = 0.05;
@export var min_zoom:float = 0.1;
@export var max_zoom:float = 2;
@export var is_sprint_toggle:bool = false

var is_sprinting:bool = false;
var speed:float;
var can_alter_camera:bool = true;
var is_moving:bool = false;
var motion_status:CameraMotion = CameraMotion.STATIC;

func _ready() -> void:
	speed = default_speed;


func _process(delta: float) -> void:
	if can_alter_camera:
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
		elif Input.is_action_just_pressed("camera_zoom_in"):
			if zoom == Vector2(max_zoom, max_zoom):
				return;
			elif zoom + Vector2(zoom_strength, zoom_strength) > Vector2(max_zoom, max_zoom):
				zoom = Vector2(max_zoom, max_zoom)
			else:
				zoom += Vector2(zoom_strength, zoom_strength);
		elif Input.is_action_just_pressed("camera_zoom_out"):
			if zoom == Vector2(min_zoom, min_zoom):
				return;
			elif zoom - Vector2(zoom_strength, zoom_strength) < Vector2(min_zoom, min_zoom):
				zoom = Vector2(min_zoom, min_zoom)
			else:
				zoom -= Vector2(zoom_strength, zoom_strength);



func move_camera(motion:CameraMotion, delta: float):
	is_moving = true;
	match motion:
		CameraMotion.LEFT:
			"""
				If statment is needed so that the position doesn't 
					still move in a direction while the camera is not.
			"""
			#if not (position <= Vector2(limit_left,0)): 
			position -= Vector2(speed * delta, 0)
		CameraMotion.RIGHT:
			#if not (position >= Vector2(limit_right, 0)):
			position += Vector2(speed * delta, 0)
		CameraMotion.UP:
			#if not (position <= Vector2(0, limit_top)): 
			position -= Vector2(0, speed * delta)
		CameraMotion.DOWN:
			#if not (position >= Vector2(0, limit_bottom)):
			position += Vector2(0, speed * delta)
