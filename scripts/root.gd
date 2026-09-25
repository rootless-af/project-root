extends Node2D

# -- Refs --
#@onready var root_path: Path2D = $RootPath;
@onready var root_lifetime: Timer = $RootLifetime
#@onready var root_line: Line2D = $RootPath/RootLine

# -- Growth --

@export var growth_speed: float = 400.0;
#@export var growth_interval: float = 0.005;
@export var segment_length: float = 8.0;
@export var max_active_tips: int = 10;

#var growth_timer: float = 0.0;

# -- Rendering --

@export var root_texture: Texture2D;
@export var root_width: float = 200.0;

# -- Root shape --

#@export var downward_bias: float = 1.0;
@export var randomness: float = 0.15;

#var root_direction := Vector2(0,1);

# -- Genetics -- ( W I P )

@export var max_depth: float = 2000.0;
@export var rock_penetration: float = 0.0;
@export var clay_penetration: float = 0.0;

@export_range(0.0,1.0)
var direction_stability: float = 0.85; # How strongly the root prefers to go downward

@export_range(0.0,1.0)
var split_chance: float = 0.01;

# -- State --

var root_tips: Array[RootTip] = [];
var segments: Array[RootSegment] = [];

var current_depth: float = 0.0;
var total_length: float = 0.0;
var is_growing: bool = false;

#var current_direction := Vector2(0,1);

func _ready() -> void:
	setup_root();
	root_lifetime.timeout.connect(_on_lifetime_finished)

func setup_root() -> void:
	root_tips.clear();
	segments.clear();
	
	var main_line := create_root_line();
	main_line.add_point(Vector2.ZERO);
	#var curve := Curve2D.new()
	
	# Starting point
	#curve.add_point(Vector2.ZERO);
	#root_path.curve = curve;
	#root_line.clear_points();
	#root_line.add_point(Vector2.ZERO);
	
	var main_tip := RootTip.new(
		Vector2.ZERO,
		Vector2.DOWN,
		main_line
	)
	
	root_tips.append(main_tip)
	
	is_growing = true;

func create_root_line() -> Line2D:
	var line := Line2D.new();
	
	line.width = root_width;
	line.texture = root_texture;
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED;
	
	line.texture_mode = Line2D.LINE_TEXTURE_TILE;
	line.joint_mode = Line2D.LINE_JOINT_ROUND;
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND;
	line.end_cap_mode =Line2D.LINE_CAP_ROUND;
	
	add_child(line);
	return line;

func _process(delta: float) -> void:
	if not is_growing:
		return;
	
	grow(delta);

func grow(delta: float) -> void:
	var tip_count := root_tips.size();
	
	for i in range(tip_count):
		var tip := root_tips[i];
		
		if not tip.growing:
			continue;
		
		grow_tip(tip, delta);
	
	#var curve := root_path.curve;
	
	#if curve == null:
	#	return;
	
	#var last_point := curve.get_point_position(curve.point_count - 1);
	
	#var direction := calculate_growth_direction();
	
	# Calculate next position
	
	#var movement := direction * growth_interval * growth_speed;
	#var next_point := last_point + movement;
	
	# Check maximimum deapth
	
	#current_depth = next_point.y;
	
	#if(current_depth >= max_depth):
	#	stop_growth();
	#	return;
	
	# Add point
	#curve.add_point(next_point)
	#root_line.add_point(next_point)
	
	# Branching
	#if randf() < split_chance:
	#	create_branch(next_point,direction);

func grow_tip(tip: RootTip, delta: float) -> void:
	tip.previous_position = tip.position;
	
	var direction := calculate_growth_direction(tip);
	
	var movement := direction * growth_speed * delta;
	
	var next_position := tip.position + movement;
	
	# Max depth
	if next_position.y >= max_depth:
		tip.growing = false;
		return;
	
	# Update tip
	tip.position = next_position;
	tip.distance_since_segment += movement.length();
	
	# Create geometry
	if tip.distance_since_segment >= segment_length:
		create_segment(tip);
		
		tip.distance_since_segment = 0.0;
	
	current_depth = max(
		current_depth,
		next_position.y
	);

func calculate_growth_direction(tip: RootTip) -> Vector2:
	var random_angle := randf_range(
		-randomness,
		randomness
	);
	
	tip.direction = tip.direction.rotated(random_angle);
	
	# Downwards bias
	if tip.direction.y < 0.5:
		tip.direction.y = 0.5;
	
	tip.direction = tip.direction.normalized();
	
	return tip.direction;

func create_branch(position: Vector2, parent_direction: Vector2) -> void:
	if root_tips.size() >= max_active_tips:
		return;
	
	var branch_direction := parent_direction.rotated(
		randf_range(-0.8,0.8)
	);
	
	branch_direction.y = abs(branch_direction.y);
	
	branch_direction = branch_direction.normalized();
	var branch_line := create_root_line();
	branch_line.add_point(position);	
	
	var branch := RootTip.new(
		position,
		branch_direction,
		branch_line
	);
	
	root_tips.append(branch);

func create_segment(tip: RootTip) -> void:
	var segment := RootSegment.new(
		tip.previous_position,
		tip.position
	);
	
	segments.append(segment);
	
	total_length += segment.length;
	
	# Render
	tip.line.add_point(tip.position);
	
	# Branching
	if randf() < split_chance:
		create_branch(tip.position, tip.direction);

func stop_growth() -> void:
	is_growing = false;

func _on_lifetime_finished() -> void:
	stop_growth();

class RootTip:
	var position: Vector2;
	var previous_position: Vector2;
	var direction: Vector2;
	var line: Line2D;
	var growing: bool = true;
	var distance_since_segment: float = 0.0;
	
	func _init(start_position: Vector2, start_direction: Vector2, start_line: Line2D):
		position = start_position;
		previous_position = start_position;
		direction = start_direction;
		line = start_line;

class RootSegment:
	var start: Vector2;
	var end: Vector2;
	var length: float
	
	func _init(start_position: Vector2, end_position: Vector2):
		start = start_position;
		end = end_position;
		length = start.distance_to(end);
