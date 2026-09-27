extends Node
class_name recourse_coordinates_generation

@export_group("DEBUG")
@export var debug_messages: bool = false;

var map_width = GLOBALS.map_width
var viewport_y = GLOBALS.map_height - 260
@onready var mineral_spawner: MineralSpawner = $MineralSpawner

var noise_seed = 720343699  #Should be randomly generated seed, for randomly generated noice (but that later)
var noise_frequency = 0.5338 # We should probably evaluate how good that is.

#------------
# Low surface resource
#-----------
var low_surface_materials_noise := FastNoiseLite.new();
#var low_surface_materials_noise_frequency: float = 0.0153 # We need a mechanism for generating the seeds
var low_surface_materials_noise_frequency: float = 0.1
var low_surface_start: int = 0
var low_surface_end: int = 2250
var low_resource_threshold: float = GLOBALS.low_ground_resource_threshold
#var low_resource_threshold: float = 0.49
var low_layer_ores = [
	GLOBALS.Minerals.Entivera,
]

#------------
# Mid surface resource
#-----------
var mid_surface_materials_noise := FastNoiseLite.new();
var mid_surface_materials_noise_frequency: float = 0.074
var mid_surface_start: int = 2250
var mid_surface_end: int =  mid_surface_start + 2250
var mid_resource_threshold: float = GLOBALS.mid_ground_resource_threshold
var mid_layer_ores = [
	GLOBALS.Minerals.Barbanium,
	GLOBALS.Minerals.Rihtocide
]

#------------
# Mid-deep surface resource
#-----------
var middeep_surface_materials_noise := FastNoiseLite.new();
var middeep_surface_materials_noise_frequency: float = 0.049
var middeep_surface_start: int = mid_surface_end
#var middeep_surface_end: int =  middeep_surface_start * 2
var middeep_surface_end: int =  middeep_surface_start + 2250
var middeep_resource_threshold: float = GLOBALS.middeep_ground_resource_threshold
var middeep_layer_ores = [
	GLOBALS.Minerals.Rihtocide,
	GLOBALS.Minerals.Kviktorium
]

#------------
# Deep surface resource
#-----------
var deep_surface_materials_noise := FastNoiseLite.new();
var deep_surface_materials_noise_frequency: float = 0.031
var deep_surface_start: int = middeep_surface_end
var deep_surface_end: int = deep_surface_start + 2250
var deep_resource_threshold: float = GLOBALS.deep_ground_resource_threshold
var deep_layer_ores = [
	GLOBALS.Minerals.Kviktorium
]

var terrain_noice := FastNoiseLite.new();

@export var low_surface_resource_positions: Array[Dictionary]
@export var mid_surface_resource_positions: Array[Dictionary]
@export var middeep_surface_resource_positions: Array[Dictionary]
@export var deep_surface_resource_positions: Array[Dictionary]

var occupied_mineral_positions: Dictionary = {}
var mineral_deposits: Array[Dictionary]

var mineral_limits := {
	GLOBALS.Minerals.Entivera: 12000,
	GLOBALS.Minerals.Barbanium: 8000,
	GLOBALS.Minerals.Rihtocide: 6000,
	GLOBALS.Minerals.Kviktorium: 4000
}

var mineral_spawned := {
	GLOBALS.Minerals.Entivera: 0,
	GLOBALS.Minerals.Barbanium: 0,
	GLOBALS.Minerals.Rihtocide: 0,
	GLOBALS.Minerals.Kviktorium: 0
}

func find_resource_deposits() -> void:
	var rng := RandomNumberGenerator.new()
	var deposit_generator := Deposit_Generator.new()
	var sample_coordinates_x = map_width
	var sample_coordinates_y = viewport_y
	var candidate_spacing = 4
	
	
	for x in range(0, map_width, candidate_spacing): 
		
		for y in range(low_surface_start, low_surface_end): 
			var position: Vector2i = Vector2i(x, y)
			
			if is_position_available(position, 9) :
				var noise_volume_value := low_surface_materials_noise.get_noise_2d(x, y)
				if noise_volume_value > low_resource_threshold and noise_volume_value < mid_resource_threshold :
					if rng.randf() > 0.35:
						var mineral_type = get_random_mineral(low_layer_ores)
						var ore_deposit = deposit_generator.couple_ore_vein(noise_volume_value, Vector2i(x, y), mineral_type)
						if !ore_deposit.is_empty() :
							mineral_deposits.append(ore_deposit)
							occupied_mineral_positions[position] = true
				
		for y in range(mid_surface_start, mid_surface_end):
			var position: Vector2i = Vector2i(x, y)
			
			if is_position_available(position, 4) :
				var noise_volume_value = mid_surface_materials_noise.get_noise_2d(x, y)
				if noise_volume_value > mid_resource_threshold :
					if rng.randf() > 0.45:
						var mineral_type = get_random_mineral(mid_layer_ores)
						var ore_deposit = deposit_generator.couple_ore_vein(noise_volume_value, Vector2i(x, y), mineral_type)
						if !ore_deposit.is_empty() :
							#mid_surface_resource_positions.append(ore_deposit)
							mineral_deposits.append(ore_deposit)
							occupied_mineral_positions[position] = true
				
		for y in range(middeep_surface_start, middeep_surface_end):
			var position: Vector2i = Vector2i(x, y)
			
			if is_position_available(position, 5) :
				var noise_volume_value = middeep_surface_materials_noise.get_noise_2d(x, y)
				if noise_volume_value > middeep_resource_threshold:
					if rng.randf() > 0.45:
						var mineral_type = get_random_mineral(middeep_layer_ores)
						var ore_deposit = deposit_generator.couple_ore_vein(noise_volume_value, Vector2i(x, y), mineral_type)
						if !ore_deposit.is_empty() :
							#middeep_surface_resource_positions.append(ore_deposit)
							mineral_deposits.append(ore_deposit)
							occupied_mineral_positions[position] = true
				
		for y in range(deep_surface_start, deep_surface_end):	
			var position: Vector2i = Vector2i(x, y)
			
			if is_position_available(position, 4) :
				var noise_volume_value = deep_surface_materials_noise.get_noise_2d(x, y)
				if noise_volume_value > deep_resource_threshold:
					if rng.randf() > 0.46:
						var mineral_type = get_random_mineral(deep_layer_ores)
						var ore_deposit = deposit_generator.couple_ore_vein(noise_volume_value, Vector2i(x, y), mineral_type)
						if not ore_deposit.is_empty()   :
							#deep_surface_resource_positions.append(ore_deposit)
							mineral_deposits.append(ore_deposit)
							occupied_mineral_positions[position] = true
	if debug_messages:
		var low_surface_pos_string := "";
		for resource in low_surface_resource_positions:
			low_surface_pos_string += str(resource.coordinates) + ", ";
		print("[Terrain Generator] low_surface_resource_positions: [", low_surface_pos_string, "]");
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Currently not used for anything
	terrain_noice.seed = noise_seed
	terrain_noice.TYPE_PERLIN;
	#=================
		
	low_surface_materials_noise.frequency = low_surface_materials_noise_frequency
	low_surface_materials_noise.seed = noise_seed + 100
	low_surface_materials_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	mid_surface_materials_noise.frequency = mid_surface_materials_noise_frequency
	mid_surface_materials_noise.seed = noise_seed + 200
	mid_surface_materials_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	middeep_surface_materials_noise.frequency = middeep_surface_materials_noise_frequency
	middeep_surface_materials_noise.seed = noise_seed + 270
	middeep_surface_materials_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	deep_surface_materials_noise.frequency = deep_surface_materials_noise_frequency
	deep_surface_materials_noise.seed = noise_seed + 360
	deep_surface_materials_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	find_resource_deposits()
	mineral_deposits.shuffle()
	
	for deposit in mineral_deposits:

		if deposit.coordinates[0] <= 251:
			continue

		var mineral_type = deposit.type

		if not mineral_limits.has(mineral_type):
			continue

		if mineral_spawned[mineral_type] >= mineral_limits[mineral_type]:
			continue

		mineral_spawner.initialize_material(
			deposit.coordinates,
			deposit.richness,
			deposit.type
		)

		mineral_spawned[mineral_type] += 1
			
func is_position_available(
	position: Vector2i,
	radius: int
) -> bool:

	for x_offset in range(-radius, radius + 1):
		for y_offset in range(-radius, radius + 1):
			# Ignore positions outside a circular radius.
			if (
				x_offset * x_offset
				+ y_offset * y_offset
				> radius * radius
			):
				continue
			var neighbour := position + Vector2i(
				x_offset,
				y_offset
			)
			if occupied_mineral_positions.has(neighbour):
				return false

	return true

func get_random_mineral(allowed_minerals: Array):
	return allowed_minerals.pick_random()
	
func calculate_layer_overlap(previous_layer_end) -> int:
	var overlap := randi_range(50, 150)
	return previous_layer_end - overlap
