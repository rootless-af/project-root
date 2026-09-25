extends Node2D

# -- Refs --
@onready var root_path: Path2D = $RootPath;
@onready var root_lifetime: Timer = $RootLifetime
@onready var root_line: Line2D = $RootPath/RootLine

# -- Growth --

@export var growth_speed: float = 40.0;
@export var growth_interval: float = 0.15;

var growth_timer: float = 0.0;

# -- Root shape --

@export var downward_bias: float = 1.0;
@export var randomness: float = 150.0;

var root_direction := Vector2(0,1);

# -- Genetics -- ( W I P )

@export var max_depth: float = 1000.0;
@export var rock_penetration: float = 0.0;
@export var clay_penetration: float = 0.0;

@export_range(0.0,1.0)
var direction_stability: float = 0.85; # How strongly the root prefers to go downward

# -- State --

var current_depth: float = 0.0;
var is_growing: bool = false;

func _ready() -> void:
	setup_root();
	root_lifetime.timeout.connect(_on_lifetime_finished)

func setup_root() -> void:
	var curve := Curve2D.new()
	
	# Starting point
	curve.add_point(Vector2.ZERO);
	root_path.curve = curve;
	root_line.clear_points();
	root_line.add_point(Vector2.ZERO);
	
	is_growing = true;

func _process(delta: float) -> void:
	if not is_growing:
		return;
	
	growth_timer += delta;
	
	if growth_timer >= growth_interval:
		growth_timer -= growth_interval;
		grow();

func grow() -> void:
	var curve := root_path.curve;
	
	if curve == null:
		return;
	
	var last_point := curve.get_point_position(curve.point_count - 1);
	
	# Generate slightly randomized direction
	
	var random_x := randf_range(-randomness,randomness);
	
	var direction := Vector2(
		random_x,
		growth_speed
	)
	
	# Mostly downwards
	direction.y *= downward_bias;
	
	# Calculate next position
	
	var movement := direction * growth_interval;
	var next_point := last_point + movement;
	
	# Check maximimum deapth
	
	current_depth = next_point.y;
	
	if(current_depth >= max_depth):
		stop_growth();
		return;
	
	# Add point
	curve.add_point(next_point)
	root_line.add_point(next_point)

func stop_growth() -> void:
	is_growing = false;

func _on_lifetime_finished() -> void:
	stop_growth();
