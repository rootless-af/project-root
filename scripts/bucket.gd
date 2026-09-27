class_name Bucket
extends Node2D

enum BucketType {
	NORMAL,
	WATER,
	FIRE,
	METAL,
	ALIEN
}

# -- Refs --
@onready var bucket_sprite: Sprite2D = $BucketSprite
@onready var bucket_area: Area2D = $Area2D
var store: Store;


# -- Resources --
@export_group("Bucket Resources")
@export var normal_bucket_texture: Texture2D;
@export var water_bucket_texture: Texture2D;
@export var fire_bucket_texture: Texture2D;
@export var metal_bucket_texture: Texture2D;
@export var alien_bucket_texture: Texture2D;

@export var error_bucket_texture: Texture2D;

@export_subgroup("Seed")
@export var seed_scene: PackedScene; 

# -- Settings --
@export_group("Settings")
@export var bucket_type: BucketType = BucketType.NORMAL;
@export var cost_per_seed: int = 100;

func _ready() -> void:
	match(bucket_type):
		BucketType.NORMAL:
			bucket_sprite.texture = normal_bucket_texture;
		BucketType.WATER:
			bucket_sprite.texture = water_bucket_texture;
		BucketType.FIRE:
			bucket_sprite.texture = fire_bucket_texture;
		BucketType.METAL:
			bucket_sprite.texture = metal_bucket_texture;
		BucketType.ALIEN:
			bucket_sprite.texture = alien_bucket_texture;
		_:
			bucket_sprite.texture = error_bucket_texture;


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			grab_seed();

func grab_seed() -> void:
	if seed_scene == null:
		push_error("Bucket has no seed scene u dummy!");
		return;
	
	if store == null:
		push_error("Bucket has no store reference u dum dum!");
		return;
	
	var seed := seed_scene.instantiate();
	
	match(bucket_type):
		BucketType.NORMAL:
			seed.seed_type = Seed.SeedType.NORMAL;
		BucketType.WATER:
			seed.seed_type = Seed.SeedType.WATER;
		BucketType.FIRE:
			seed.seed_type = Seed.SeedType.FIRE;
		BucketType.METAL:
			seed.seed_type = Seed.SeedType.METAL;
		BucketType.ALIEN:
			seed.seed_type = Seed.SeedType.ALIEN;
	
	var world := get_tree().current_scene;
	
	world.add_child(seed);
	
	var camera := get_viewport().get_camera_2d();
	
	if camera == null:
		push_error("No active Camera2D!");
		seed.queue_free();
		return;
	
	var mouse_position := camera.get_global_mouse_position();
	seed.global_position = mouse_position;
	seed.start_drag(mouse_position); 
	
	store.close_store();
	camera.enter_planting_view();
