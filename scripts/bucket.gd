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
@onready var tool_tip: ToolTip = $ToolTip

var store: Store

# -- Resources --
@export_group("Bucket Resources")
@export var normal_bucket_texture: Texture2D
@export var normal_bucket_pickup_sfx: AudioShot
@export var water_bucket_texture: Texture2D
@export var water_bucket_pickup_sfx: AudioShot
@export var fire_bucket_texture: Texture2D
@export var fire_bucket_pickup_sfx: AudioShot
@export var metal_bucket_texture: Texture2D
@export var metal_bucket_pickup_sfx: AudioShot
@export var alien_bucket_texture: Texture2D
@export var alien_bucket_pickup_sfx: AudioShot
@export var error_bucket_texture: Texture2D

var normal_minerals: Array[MineralOre] = []
var water_minerals: Array[MineralOre] = []
var fire_minerals: Array[MineralOre] = []
var metal_minerals: Array[MineralOre] = []
var alien_minerals: Array[MineralOre] = []

var normal_obstacles: Array[Obstacle] = []
var water_obstacles: Array[Obstacle] = []
var fire_obstacles: Array[Obstacle] = []
var metal_obstacles: Array[Obstacle] = []
var alien_obstacles: Array[Obstacle] = []

@export_subgroup("Seed")
@export var seed_scene: PackedScene

# -- Settings --
@export_group("Settings")
@export var bucket_type: BucketType = BucketType.NORMAL

@export_group("Shop")
@export var unlock_cost: Dictionary[GLOBALS.Minerals, int] = {}
@export var seed_cost: Dictionary[GLOBALS.Minerals, int] = {}
@export var tooltip_text: String

var normal_upgrades: Array[Upgrade] = []
var water_upgrades: Array[Upgrade] = []
var fire_upgrades: Array[Upgrade] = []
var metal_upgrades: Array[Upgrade] = []
var alien_upgrades: Array[Upgrade] = []

var audio_grab: AudioShot
var is_unlocked: bool = false

const LOCKED_MODULATE := Color(0.35, 0.35, 0.35, 1.0)
const UNLOCKED_MODULATE := Color.WHITE


func _ready() -> void:
	# Make sure the tooltip is configured before use.
	tool_tip.set_tooltip_text(tooltip_text)

	is_unlocked = bucket_type == BucketType.NORMAL

	update_tooltip_cost()
	update_bucket_visual()


func update_tooltip_cost() -> void:
	if not is_unlocked:
		tool_tip.set_amount(
			unlock_cost.get(GLOBALS.Minerals.Entivera, 0),
			unlock_cost.get(GLOBALS.Minerals.Barbanium, 0),
			unlock_cost.get(GLOBALS.Minerals.Rihtocide, 0),
			unlock_cost.get(GLOBALS.Minerals.Kviktorium, 0)
		)
	else:
		tool_tip.set_amount(
			seed_cost.get(GLOBALS.Minerals.Entivera, 0),
			seed_cost.get(GLOBALS.Minerals.Barbanium, 0),
			seed_cost.get(GLOBALS.Minerals.Rihtocide, 0),
			seed_cost.get(GLOBALS.Minerals.Kviktorium, 0)
		)


func update_bucket_visual() -> void:
	match bucket_type:
		BucketType.NORMAL:
			bucket_sprite.texture = normal_bucket_texture
			audio_grab = normal_bucket_pickup_sfx

		BucketType.WATER:
			bucket_sprite.texture = water_bucket_texture
			audio_grab = water_bucket_pickup_sfx

		BucketType.FIRE:
			bucket_sprite.texture = fire_bucket_texture
			audio_grab = fire_bucket_pickup_sfx

		BucketType.METAL:
			bucket_sprite.texture = metal_bucket_texture
			audio_grab = metal_bucket_pickup_sfx

		BucketType.ALIEN:
			bucket_sprite.texture = alien_bucket_texture
			audio_grab = alien_bucket_pickup_sfx

		_:
			bucket_sprite.texture = error_bucket_texture

	bucket_sprite.modulate = (
		UNLOCKED_MODULATE
		if is_unlocked
		else LOCKED_MODULATE
	)


func _on_area_2d_input_event(
	viewport: Node,
	event: InputEvent,
	shape_idx: int
) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not is_unlocked:
				purchase_bucket()
			else:
				grab_seed()


func purchase_bucket() -> void:
	if bucket_type == BucketType.NORMAL:
		is_unlocked = true
		update_bucket_visual()
		update_tooltip_cost()
		return

	if unlock_cost.is_empty():
		is_unlocked = true
		update_bucket_visual()
		update_tooltip_cost()
		return

	if Inventory.make_transaction(unlock_cost):
		is_unlocked = true
		update_bucket_visual()
		update_tooltip_cost()

		print(
			"[Bucket] Unlocked: ",
			BucketType.keys()[bucket_type]
		)
	else:
		print("[Bucket] Not enough minerals to unlock bucket")


func grab_seed() -> void:
	if seed_scene == null:
		push_error("Bucket has no seed scene!")
		return

	if store == null:
		push_error("Bucket has no store reference!")
		return

	if not Inventory.make_transaction(seed_cost):
		print("[Bucket] Not enough minerals for seed")
		return

	var seed: Seed = seed_scene.instantiate()

	match bucket_type:
		BucketType.NORMAL:
			seed.seed_type = Seed.SeedType.NORMAL
			seed.minerals = normal_minerals
			seed.obstacles = normal_obstacles

			for upgrade in normal_upgrades:
				seed.normal_upgrades.append(upgrade.duplicate())

		BucketType.WATER:
			seed.seed_type = Seed.SeedType.WATER
			seed.minerals = water_minerals
			seed.obstacles = water_obstacles

			for upgrade in water_upgrades:
				seed.water_upgrades.append(upgrade.duplicate())

		BucketType.FIRE:
			seed.seed_type = Seed.SeedType.FIRE
			seed.minerals = fire_minerals
			seed.obstacles = fire_obstacles

			for upgrade in fire_upgrades:
				seed.fire_upgrades.append(upgrade.duplicate())

		BucketType.METAL:
			seed.seed_type = Seed.SeedType.METAL
			seed.minerals = metal_minerals
			seed.obstacles = metal_obstacles

			for upgrade in metal_upgrades:
				seed.metal_upgrades.append(upgrade.duplicate())

		BucketType.ALIEN:
			seed.seed_type = Seed.SeedType.ALIEN
			seed.minerals = alien_minerals
			seed.obstacles = alien_obstacles

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


# -------------------------------------------------------------------
# UPGRADES
# -------------------------------------------------------------------

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


# -------------------------------------------------------------------
# MINERALS
# -------------------------------------------------------------------

func _on_store_normal_tree_minerals_initialized(
	minerals: Array[MineralOre]
) -> void:
	normal_minerals = minerals


func _on_store_water_tree_minerals_initialized(
	minerals: Array[MineralOre]
) -> void:
	water_minerals = minerals


func _on_store_fire_tree_minerals_initialized(
	minerals: Array[MineralOre]
) -> void:
	fire_minerals = minerals


func _on_store_metal_tree_minerals_initialized(
	minerals: Array[MineralOre]
) -> void:
	metal_minerals = minerals


func _on_store_alien_tree_minerals_initialized(
	minerals: Array[MineralOre]
) -> void:
	alien_minerals = minerals


# -------------------------------------------------------------------
# OBSTACLES
# -------------------------------------------------------------------

func _on_store_normal_tree_obstacles_initialized(
	obstacles: Array[Obstacle]
) -> void:
	normal_obstacles = obstacles


func _on_store_water_tree_obstacles_initialized(
	obstacles: Array[Obstacle]
) -> void:
	water_obstacles = obstacles


func _on_store_fire_tree_obstacles_initialized(
	obstacles: Array[Obstacle]
) -> void:
	fire_obstacles = obstacles


func _on_store_metal_tree_obstacles_initialized(
	obstacles: Array[Obstacle]
) -> void:
	metal_obstacles = obstacles


func _on_store_alien_tree_obstacles_initialized(
	obstacles: Array[Obstacle]
) -> void:
	alien_obstacles = obstacles


# -------------------------------------------------------------------
# TOOLTIP
# -------------------------------------------------------------------

func _on_area_2d_mouse_entered() -> void:
	print("hi")
	tool_tip.set_tooltip_visible(true)


func _on_area_2d_mouse_exited() -> void:
	tool_tip.set_tooltip_visible(false)
