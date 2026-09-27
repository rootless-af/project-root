extends Node2D

signal reached_threshold(threshold: GLOBALS.Levels)

enum RootType {
	NORMAL,
	WATER,
	FIRE,
	METAL,
	ALIEN
}

# -- Refs --
#@onready var root_path: Path2D = $RootPath;
@onready var root_lifetime: Timer = $RootLifetime
@onready var game_manager: Node2D = $"../GameManager"
#@onready var root_line: Line2D = $RootPath/RootLine

# -- Health --
@export var health: int = 1000
var dead:= false

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

# -- Root Identifiers --
@export var root_type: RootType = RootType.NORMAL;

# -- Genetics -- ( W I P )

@export var max_depth: float = 2000.0;
@export var min_depth: float = 1000.0;

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
var reached_mid_level:= false
var reached_mid_deep_level:= false
var reached_deep_level:= false
var reached_core_level:= false

var total_length: float = 0.0;
var is_growing: bool = false;


# -- Mineral Mining --
var minerals: Array[MineralOre] = []
@export var mineral_detection_radius: float = 100.0
var gather_amount := 1
var gather_speed := 0.5
var mining_operations: Array[MiningOperation] = []


# -- Obstacles --
var obstacles: Array[Obstacle] = []
@export var obstacle_detection_radius: float = 100.0
var obstacle_operations: Array[ObstacleMiningOperation] = []

#var current_direction := Vector2(0,1);

func _ready() -> void:
	reached_threshold.connect(game_manager._on_root_reached_threshold)
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
		main_line,
		max_depth
	)
	
	root_tips.append(main_tip)
	
	is_growing = true;
	
	match(root_type):
		RootType.NORMAL:
			MusicManager.register_root("normal");
		RootType.WATER:
			MusicManager.register_root("water");
		RootType.FIRE:
			MusicManager.register_root("fire");
		RootType.METAL:
			MusicManager.register_root("metal");
		RootType.ALIEN:
			MusicManager.register_root("alien");

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

func set_obstacles(value: Array[Obstacle]) -> void:
	obstacles = value



func set_minerals(value: Array[MineralOre]) -> void:
	minerals = value

func _process(delta: float) -> void:
	if not is_growing:
		return;
	grow(delta);
	check_depth_progress()
	

func check_depth_progress():
	if !reached_mid_level:
		if current_depth >= GLOBALS.level_depths.get(GLOBALS.Levels.MID_LEVEL):
			reached_mid_level = true
			reached_threshold.emit(GLOBALS.Levels.MID_LEVEL)
	if !reached_mid_deep_level:
		if current_depth >= GLOBALS.level_depths.get(GLOBALS.Levels.MID_DEEP_LEVEL) and not reached_mid_deep_level:
			reached_mid_deep_level = true
			reached_threshold.emit(GLOBALS.Levels.MID_DEEP_LEVEL)
	if !reached_deep_level:
		if current_depth >= GLOBALS.level_depths.get(GLOBALS.Levels.DEEP_LEVEL) and not reached_deep_level:
			reached_deep_level = true;
			reached_threshold.emit(GLOBALS.Levels.DEEP_LEVEL)
	if !reached_core_level:
		if current_depth >= GLOBALS.level_depths.get(GLOBALS.Levels.CORE) and not reached_core_level:
			reached_core_level = true;
			reached_threshold.emit(GLOBALS.Levels.CORE)

func grow(delta: float) -> void:
	var tip_count := root_tips.size();
	
	for i in range(tip_count):
		var tip := root_tips[i];
		
		if not tip.growing or tip.blocked:
			continue;
		
		grow_tip(tip, delta);
		
	# Check if all tips finished growing. (Music Manager)
	if all_tips_finished():
		stop_growth();
	
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
	tip.previous_position = tip.position

	var direction := calculate_growth_direction(tip)
	var movement := direction * growth_speed * delta
	var next_position := tip.position + movement

	if next_position.y >= tip.final_depth:
		tip.growing = false
		return

	# Convert BOTH points from root-local space to world space.
	var current_global_position := to_global(tip.position)
	var next_global_position := to_global(next_position)

	var obstacle := get_obstacle_in_path(
		current_global_position,
		next_global_position
	)

	if obstacle != null:
		handle_obstacle(tip, obstacle)
		return

	# Only update the tip if nothing blocked the movement.
	tip.position = next_position

	tip.distance_since_segment += movement.length()

	if tip.distance_since_segment >= segment_length:
		create_segment(tip)
		tip.distance_since_segment = 0.0

	current_depth = max(
		current_depth,
		next_global_position.y
	)

func get_obstacle_in_path(start_global: Vector2, end_global: Vector2) -> Obstacle:
	for obstacle in obstacles:
		if not is_instance_valid(obstacle):
			continue

		if obstacle.depleted:
			continue

		var closest_point := Geometry2D.get_closest_point_to_segment(
			obstacle.global_position,
			start_global,
			end_global
		)
		var distance := obstacle.global_position.distance_to(closest_point)
		if distance <= obstacle_detection_radius:
			return obstacle

	return null
	
func get_obstacle_penetration(obstacle: Obstacle) -> float:
	
	match obstacle.type:
		Obstacle.ObstacleType.CLAY:
			return clay_penetration
		Obstacle.ObstacleType.ROCK:
			return rock_penetration

	return 0.0


func can_penetrate_obstacle(obstacle: Obstacle) -> bool:
	return get_obstacle_penetration(obstacle) > 0.0


func handle_obstacle(tip: RootTip, obstacle: Obstacle) -> void:
	if not can_penetrate_obstacle(obstacle):
		tip.growing = false
		return

	tip.blocked = true

	start_mining_obstacle(obstacle, tip)


func start_mining_obstacle(
	obstacle: Obstacle,
	tip: RootTip
) -> void:

	for operation in obstacle_operations:
		if operation.obstacle == obstacle:
			return
	var operation := ObstacleMiningOperation.new(
		obstacle,
		self,
		tip,
		get_obstacle_penetration(obstacle),
		gather_speed
	)
	obstacle_operations.append(operation)

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
	if not dead:
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
			branch_line,
			randf_range(min_depth,max_depth)
		);

		root_tips.append(branch);

func create_segment(tip: RootTip) -> void:
	if not dead:
		var segment := RootSegment.new(
			tip.previous_position,
			tip.position
		);
		
		segments.append(segment);
		
		total_length += segment.length;
		
		# Render
		tip.line.add_point(tip.position);
		check_segment_for_minerals(segment, tip)
		# Branching
		if randf() < split_chance:
			create_branch(tip.position, tip.direction);

func die():
	dead = true
	stop_growth()


func stop_growth() -> void:
	
	is_growing = false;
	
	match(root_type):
		RootType.NORMAL:
			MusicManager.unregister_root("normal");
		RootType.WATER:
			MusicManager.unregister_root("water");
		RootType.FIRE:
			MusicManager.unregister_root("fire");
		RootType.METAL:
			MusicManager.unregister_root("metal");
		RootType.ALIEN:
			MusicManager.unregister_root("alien");

func _on_lifetime_finished() -> void:
	stop_growth();

func all_tips_finished() -> bool:
	for tip in root_tips:
		if tip.growing:
			return false

	return true


func check_segment_for_minerals(segment: RootSegment,tip: RootTip) -> void:
	var segment_start := to_global(segment.start)
	var segment_end := to_global(segment.end)
	for mineral in minerals:
		if not is_instance_valid(mineral):
			continue
		var closest_point := Geometry2D.get_closest_point_to_segment(
			mineral.global_position,
			segment_start,
			segment_end
		)
		var distance := mineral.global_position.distance_to(closest_point)

		if distance <= mineral_detection_radius:
			start_mining(mineral, tip)
		

func start_mining(mineral: MineralOre, tip: RootTip) -> void:
	for operation in mining_operations:
		if operation.mineral == mineral:
			return
	var operation := MiningOperation.new(mineral, self, gather_amount, gather_speed)
	operation.mineral_damage.connect(_on_mineral_damage)
	mining_operations.append(operation)

func _on_mineral_damage(amount:int):
	if health - amount == 0:
		health = 0
		die()
	else:
		health -= amount



class RootTip:
	var position: Vector2;
	var previous_position: Vector2;
	var direction: Vector2;
	var line: Line2D;
	var blocked: bool = false;
	var growing: bool = true;
	var distance_since_segment: float = 0.0;
	
	var final_depth : float;
	
	func _init(start_position: Vector2, start_direction: Vector2, start_line: Line2D, finished_depth: float):
		position = start_position;
		previous_position = start_position;
		direction = start_direction;
		line = start_line;
		final_depth = finished_depth;

class RootSegment:
	var start: Vector2;
	var end: Vector2;
	var length: float
	
	func _init(start_position: Vector2, end_position: Vector2):
		start = start_position;
		end = end_position;
		length = start.distance_to(end);


class MiningOperation:
	var mineral: MineralOre
	var timer: Timer
	var root: Node2D
	var gather_amount:int
	
	signal mineral_damage(damage:int)

	func _init(mineral_to_mine: MineralOre, mining_root: Node2D, gather_amount:int, gather_speed:float) -> void:
		mineral = mineral_to_mine
		root = mining_root
		self.gather_amount = gather_amount
		
		timer = Timer.new()
		timer.one_shot = false
		timer.wait_time = gather_speed

		root.add_child(timer)
		timer.timeout.connect(_on_timer_timeout)

		timer.start()

	func _on_timer_timeout() -> void:
		if not is_instance_valid(mineral):
			stop()
			return

		mineral.mine_material(gather_amount)
		mineral_damage.emit(mineral.damage_dealt)
		if mineral.amount <= 0:
			mineral.amount = 0
			stop()
			mineral.queue_free()

	func stop() -> void:
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()
		
		root.mining_operations.erase(self)


class ObstacleMiningOperation:
	var obstacle: Obstacle
	var root: Node2D
	var tip: RootTip
	var timer: Timer
	var damage: float

	func _init(
		obstacle_to_mine: Obstacle,
		mining_root: Node2D,
		mining_tip: RootTip,
		damage_amount: float,
		mining_speed: float
	) -> void:

		obstacle = obstacle_to_mine
		root = mining_root
		tip = mining_tip
		damage = damage_amount

		timer = Timer.new()
		timer.one_shot = false
		timer.wait_time = mining_speed

		root.add_child(timer)
		timer.timeout.connect(_on_timer_timeout)
		timer.start()

	func _on_timer_timeout() -> void:
		if not is_instance_valid(obstacle):
			stop()
			return

		# Damage the root while mining the obstacle.
		if obstacle.type == Obstacle.ObstacleType.ROCK:
			root.health -= obstacle.damage_dealt

			if root.health <= 0:
				root.health = 0
				root.die()
				stop()
				return

		# Damage the obstacle.
		obstacle.strength -= damage

		if obstacle.strength <= 0:
			obstacle.strength = 0
			obstacle.depleted = true

			tip.blocked = false

			stop()
			obstacle.queue_free()

	func stop() -> void:
		if is_instance_valid(timer):
			timer.stop()
			timer.queue_free()

		root.obstacle_operations.erase(self)
