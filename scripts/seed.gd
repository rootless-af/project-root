class_name Seed;
extends Node2D

# -- Refs --
@onready var seed_sprite: Sprite2D = $Area2D/SeedSprite
@onready var seed_area: Area2D = $Area2D

@export_group("Settings")

# -- Seed Types --
enum SeedType {
	NORMAL,
	WATER,
	FIREPLANT,
	METAL
}
@export var seed_type: SeedType = SeedType.NORMAL;

# -- Falling --
@export var gravity: float = 1200.0;
@export var max_falling_speed: float = 1000.0;

var velocity: Vector2 = Vector2.ZERO;

# -- Dragging --
var is_dragging: bool = false;
var is_falling: bool = false;
var is_planted: bool = false; 

var drag_offset: Vector2 = Vector2.ZERO;

# -- Ground Detection --

const GROUND_MASK := 2; # Collision layer

@export var seed_bottom_offset: float = 16.0; # Distance from seed container to its bottom
@export var ground_ray_length: float = 20.0;

# -- Resources --
var root_scene: PackedScene;
var root_offset := Vector2(0,-115);


@export_group("Seed References")
# NORMAL 
@export var seed_basic_texture: Texture2D;
@export var root_basic_scene: PackedScene;
# WATER
@export var seed_water_texture: Texture2D;
@export var root_water_scene: PackedScene;
# FIRE
@export var seed_fire_texture: Texture2D;
@export var root_fire_scene : PackedScene;


func _ready() -> void:
	setup_seed();

func setup_seed() -> void:
	match seed_type:
		SeedType.NORMAL:
			seed_sprite.texture = seed_basic_texture;
			root_scene = root_basic_scene;
			root_offset = Vector2(0, -115);
		SeedType.WATER:
			seed_sprite.texture = seed_water_texture;
			root_scene = root_water_scene;
			root_offset = Vector2(0,-90);
		SeedType.FIREPLANT:
			pass
		_:
			seed_sprite.texture = seed_basic_texture;
			root_scene = root_basic_scene;

func _on_seed_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if is_planted:
		return;
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			start_drag(event.position);

func start_drag(mouse_position: Vector2) -> void:
	is_dragging = true;
	is_falling = false;
	velocity = Vector2.ZERO;
	
	# Keeps the seed from snapping to cursor directly
	# drag_offset = global_position - mouse_position;

func _input(event: InputEvent) -> void:
	# We handle the mouse release globally cuz cursor might 
	# have moved outside the seed while draggin
	if not is_dragging:
		return;
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				release_seed();

func release_seed() -> void:
	is_dragging = false;
	is_falling = true;
	velocity = Vector2.ZERO;
	
func _physics_process(delta: float) -> void:
	if is_planted:
		return;
	if is_dragging:
		update_dragging();
	elif is_falling:
		update_falling(delta);

func update_dragging() -> void:
	var mouse_position := get_global_mouse_position();
	
	global_position = mouse_position + drag_offset;

func update_falling(delta: float) -> void:
	# Gravity
	velocity.y += gravity * delta;
	velocity.y = min(velocity.y, max_falling_speed);
	
	# Calculate where the seed would move this frame
	var movement := velocity * delta;
	var next_position := global_position + movement;
	
	# Check wether the seed will hit the ground.
	var hit := check_ground(next_position);
	
	if hit:
		plant(hit.position);
		return;
	
	global_position = next_position;

func check_ground(next_position: Vector2) -> Dictionary:
	var space_state := get_world_2d().direct_space_state;
	
	# Start the ray at the bootom of the seed
	var ray_start := (
		next_position +
		Vector2.DOWN * seed_bottom_offset
	)
	
	var ray_end := (
		ray_start +
		Vector2.DOWN * ground_ray_length
	)
	
	var query := PhysicsRayQueryParameters2D.create(
		ray_start,
		ray_end,
		GROUND_MASK
	)
	
	# We want to detect Ground Area2D
	query.collide_with_areas = true;
	query.collide_with_bodies = false;
	
	# Dont hit ourselves lol
	query.exclude = [seed_area.get_rid()]
	
	return space_state.intersect_ray(query)

func plant(ground_position: Vector2) -> void:
	if is_planted:
		return;
	
	is_planted = true;
	is_falling = false;
	is_dragging = false;
	velocity = Vector2.ZERO;
	
	# Put the seed in da ground contact point
	global_position = ground_position - Vector2.DOWN * seed_bottom_offset;
	
	spawn_root();

func spawn_root() -> void:
	if root_scene == null:
		push_error("Seed has no root_scene attached.");
		return;
	
	var root := root_scene.instantiate();
	
	# Root and seed should be siblings. (Sweet home alabama)
	get_parent().add_child(root);
	
	root.global_position = global_position - root_offset; # Magic fucking number
	
	queue_free();
