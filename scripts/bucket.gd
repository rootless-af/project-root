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
@export var normal_bucket_pickup_sfx: AudioShot;
@export var water_bucket_texture: Texture2D;
@export var water_bucket_pickup_sfx: AudioShot;
@export var fire_bucket_texture: Texture2D;
@export var fire_bucket_pickup_sfx: AudioShot;
@export var metal_bucket_texture: Texture2D;
@export var metal_bucket_pickup_sfx: AudioShot;
@export var alien_bucket_texture: Texture2D;
@export var alien_bucket_pickup_sfx: AudioShot;
@export var error_bucket_texture: Texture2D;

@export_subgroup("Seed")
@export var seed_scene: PackedScene; 

# -- Settings --
@export_group("Settings")
@export var bucket_type: BucketType = BucketType.NORMAL

@export_group("Shop")
@export var unlock_cost: Dictionary[GLOBALS.Minerals, int] = {}
@export var seed_cost: Dictionary[GLOBALS.Minerals, int] = {}

var normal_upgrades:Array[Upgrade] = []
var water_upgrades:Array[Upgrade] = []
var fire_upgrades:Array[Upgrade] = []
var metal_upgrades:Array[Upgrade] = []
var alien_upgrades:Array[Upgrade] = []

var audio_grab: AudioShot;
var is_unlocked: bool = false

func _ready() -> void:
	is_unlocked = bucket_type == BucketType.NORMAL;
	
	match(bucket_type):
		BucketType.NORMAL:
			bucket_sprite.texture = normal_bucket_texture;
			audio_grab = normal_bucket_pickup_sfx;
		BucketType.WATER:
			bucket_sprite.texture = water_bucket_texture;
			audio_grab = water_bucket_pickup_sfx;
		BucketType.FIRE:
			bucket_sprite.texture = fire_bucket_texture;
			audio_grab = fire_bucket_pickup_sfx;
		BucketType.METAL:
			bucket_sprite.texture = metal_bucket_texture;
			audio_grab = metal_bucket_pickup_sfx;
		BucketType.ALIEN:
			bucket_sprite.texture = alien_bucket_texture;
			audio_grab = alien_bucket_pickup_sfx;
		_:
			bucket_sprite.texture = error_bucket_texture;


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not is_unlocked:
				purchase_bucket()
			else:
				grab_seed()

func purchase_bucket() -> void:
	if bucket_type == BucketType.NORMAL:
		is_unlocked = true
		return
	
	if unlock_cost.is_empty():
		is_unlocked = true
		return
	
	if Inventory.make_transaction(unlock_cost):
		is_unlocked = true
		print("[Bucket] Unlocked: ", BucketType.keys()[bucket_type])
	else:
		print("[Bucket] Not enough minerals to unlock bucket")

func grab_seed() -> void:
	if seed_scene == null:
		push_error("Bucket has no seed scene u dummy!")
		return
	
	if store == null:
		push_error("Bucket has no store reference u dum dum!")
		return
	
	if not Inventory.make_transaction(seed_cost):
		print("[Bucket] Not enough minerals for seed")
		return
	
	var seed: Seed = seed_scene.instantiate()
	
	match bucket_type:
		BucketType.NORMAL:
			seed.seed_type = Seed.SeedType.NORMAL
			for upgrade in normal_upgrades:
				seed.normal_upgrades.append(upgrade.duplicate())
				
		BucketType.WATER:
			seed.seed_type = Seed.SeedType.WATER
			for upgrade in water_upgrades:
				seed.water_upgrades.append(upgrade.duplicate())
				
		BucketType.FIRE:
			seed.seed_type = Seed.SeedType.FIRE
			for upgrade in fire_upgrades:
				seed.fire_upgrades.append(upgrade.duplicate())
				
		BucketType.METAL:
			seed.seed_type = Seed.SeedType.METAL
			for upgrade in metal_upgrades:
				seed.metal_upgrades.append(upgrade.duplicate())
				
		BucketType.ALIEN:
			seed.seed_type = Seed.SeedType.ALIEN
			for upgrade in alien_upgrades:
				seed.alien_upgrades.append(upgrade.duplicate())
	
	var world := get_tree().current_scene
	world.add_child(seed)
	
	var camera := get_viewport().get_camera_2d()
	
	if camera == null:
		push_error("No active Camera2D!")
		seed.queue_free()
		return
	
	var mouse_position := camera.get_global_mouse_position()
	seed.global_position = mouse_position
	seed.start_drag(mouse_position)
	
	AudioManager.play(audio_grab)
	
	store.close_store()
	camera.enter_planting_view()


func _on_store_normal_tree_applied_upgrade(upgrade: Upgrade) -> void:
	normal_upgrades.append(upgrade)

func _on_store_water_tree_applied_upgrade(upgrade: Upgrade) -> void:
	water_upgrades.append(upgrade)

func _on_store_fire_tree_applied_upgrade(upgrade: Upgrade) -> void:
	fire_upgrades.append(upgrade)

func _on_store_metal_tree_applied_upgrade(upgrade: Upgrade) -> void:
	metal_upgrades.append(upgrade)

func _on_store_alien_tree_applied_upgrade(upgrade: Upgrade) -> void:
	alien_upgrades.append(upgrade)
