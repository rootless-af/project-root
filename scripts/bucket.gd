extends Node2D

enum BucketType {
	NORMAL,
	WATER,
	FIRE,
	METAL
}

# -- Refs --
@onready var bucket_sprite: Sprite2D = $BucketSprite
@onready var bucket_area: Area2D = $Area2D



# -- Resources --
@export_group("Bucket Resources")
@export var normal_bucket_texture: Texture2D;
@export var water_bucket_texture: Texture2D;
@export var fire_bucket_texture: Texture2D;
@export var metal_bucket_texture: Texture2D;

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
	
	get_parent().add_child(seed);
	var mouse_position := get_global_mouse_position();
	seed.global_position = mouse_position;
	seed.start_drag(mouse_position); 
