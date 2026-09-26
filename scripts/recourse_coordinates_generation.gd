extends Node

@export_group("DEBUG")
@export var debug_messages: bool = false;

var map_width = GLOBALS.map_width
var viewport_y = GLOBALS.map_height

var noise_seed = 720343699  #Should be randomly generated seed, for randomly generated noice (but that later)
var noise_frequency = 0.5338 # We should probably evaluate how good that is.

#------------
# Low surface resource
#-----------
var low_surface_materials_noise := FastNoiseLite.new();
var low_surface_materials_noise_frequency: float = 0.0153 # We need a mechanism for generating the seeds
var low_surface_start: int = 0
var low_surface_end: int = 750
var low_resource_threshold: float = GLOBALS.low_ground_resource_threshold
#var low_resource_threshold: float = 0.49

#------------
# Mid surface resource
#-----------
var mid_surface_materials_noise := FastNoiseLite.new();
var mid_surface_materials_noise_frequency: float = 0.0312
var mid_surface_start: int = calculate_layer_overlap(low_surface_end)
var mid_surface_end: int =  mid_surface_start * 2
var mid_resource_threshold: float = GLOBALS.mid_ground_resource_threshold
#var mid_resource_threshold: float = 0.36

#------------
# Mid-deep surface resource
#-----------
var middeep_surface_materials_noise := FastNoiseLite.new();
var middeep_surface_materials_noise_frequency: float = 0.0412
var middeep_surface_start: int = calculate_layer_overlap(mid_surface_end)
var middeep_surface_end: int =  middeep_surface_start * 2
var middeep_resource_threshold: float = GLOBALS.middeep_ground_resource_threshold
#var middeep_resource_threshold: float = 0.29

#------------
# Deep surface resource
#-----------
var deep_surface_materials_noise := FastNoiseLite.new();
var deep_surface_materials_noise_frequency: float = 0.0672
var deep_surface_start: int = calculate_layer_overlap(middeep_surface_end)
var deep_surface_end: int = viewport_y
var deep_resource_threshold: float = GLOBALS.deep_ground_resource_threshold
#var deep_resource_threshold: float = 0.21

var terrain_noice := FastNoiseLite.new();

@export var low_surface_resource_positions: Array[Dictionary]
@export var mid_surface_resource_positions: Array[Dictionary]
@export var middeep_surface_resource_positions: Array[Dictionary]
@export var deep_surface_resource_positions: Array[Dictionary]

func find_resource_deposits() -> void:
	var deposit_generator := Deposit_Generator.new()
	var sample_coordinates_x = map_width
	var sample_coordinates_y = viewport_y
	
	for x in range(map_width) :
		for y in range(low_surface_start, low_surface_end): 
			var noise_volume_value := low_surface_materials_noise.get_noise_2d(x, y)
			if noise_volume_value > low_resource_threshold :
				var ore_deposit = deposit_generator.couple_ore_vein(noise_volume_value, Vector2i(x, y))
				if !ore_deposit.is_empty() :
					low_surface_resource_positions.append(ore_deposit)
				
		for y in range(mid_surface_start, mid_surface_end):
			var noise_volume_value = mid_surface_materials_noise.get_noise_2d(x, y)
			if noise_volume_value > mid_resource_threshold :
				var ore_deposit = deposit_generator.couple_ore_vein(noise_volume_value, Vector2i(x, y))
				if !ore_deposit.is_empty() :
					mid_surface_resource_positions.append(ore_deposit)
				
		for y in range(middeep_surface_start, middeep_surface_end):
			var noise_volume_value = middeep_surface_materials_noise.get_noise_2d(x, y)
			if noise_volume_value > middeep_resource_threshold:
				var ore_deposit = deposit_generator.couple_ore_vein(noise_volume_value, Vector2i(x, y))
				if !ore_deposit.is_empty() :
					middeep_surface_resource_positions.append(ore_deposit)
				
		for y in range(deep_surface_start, deep_surface_end):	
			var noise_volume_value = deep_surface_materials_noise.get_noise_2d(x, y)
			if noise_volume_value > deep_resource_threshold:
				var ore_deposit = deposit_generator.couple_ore_vein(noise_volume_value, Vector2i(x, y))
				if not ore_deposit.is_empty() :
					deep_surface_resource_positions.append(ore_deposit)
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
	await find_resource_deposits()
	

func calculate_layer_overlap(previous_layer_end) -> int:
	var diviosor = randi_range(2, 6)
	
	return previous_layer_end - (previous_layer_end - diviosor)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
