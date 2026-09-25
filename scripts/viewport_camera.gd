extends Camera2D

enum CameraMotion {LEFT, RIGHT, UP, DOWN, STATIC}

@onready var timer: Timer = $Timer

@export var default_speed:float = 100.0;
@export var speed_multiple:float = 1.003;
@export var zoom_strength:float = 0.05;
@export var max_zoom:float = 2.0;
@export var min_zoom:float = 0.1;

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
		if !Input.is_anything_pressed():
			if is_moving:
				timer.start()
				is_moving = false;
		
		
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

func multiply_speed():
	if speed * speed_multiple > 300:
		speed = 300;
	else:
		speed *=speed_multiple


func move_camera(motion:CameraMotion, delta: float):
	if !timer.is_stopped():
		timer.stop()
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
	multiply_speed()

func _on_timer_timeout() -> void:
	speed = default_speed
