
extends Node
class_name recourse_coordinates_generation

@export_group("DEBUG")
@export var debug_messages: bool = false


# ============================================================
# ORE DEBUG COUNTERS
# ============================================================

var low_ore_counts: Dictionary = {}
var mid_ore_counts: Dictionary = {}
var middeep_ore_counts: Dictionary = {}
var deep_ore_counts: Dictionary = {}

const LOW_SPAWN_CHANCE: float = 0.025
const MID_SPAWN_CHANCE: float = 0.01
const MIDDEEP_SPAWN_CHANCE: float = 0.007
const DEEP_SPAWN_CHANCE: float = 0.003


# ============================================================
# MAP / RNG
# ============================================================

var rng := RandomNumberGenerator.new()

# IMPORTANT:
# GLOBALS.map_width / map_height are PIXELS.
# We generate ore positions in TILE coordinates.
var map_width: int = GLOBALS.map_width / GLOBALS.TILE_SIZE
var map_height: int = GLOBALS.map_height / GLOBALS.TILE_SIZE

@onready var mineral_spawner: MineralSpawner = $MineralSpawner

var noise_seed: int = 720343699


# ============================================================
# ORE LAYER SETTINGS
# ============================================================

# The map is ~437 tiles high.
# Divide it into four depth layers.

var layer_height: int = map_height / 4

# Small overlap between layers.
# 10 tiles = 160 pixels.
var layer_overlap: int = 10


# -------------------------
# LOW
# -------------------------

var low_surface_materials_noise := FastNoiseLite.new()
var low_surface_materials_noise_frequency: float = 0.025

var low_surface_start: int = 0
var low_surface_end: int = layer_height

var low_resource_threshold: float = GLOBALS.low_ground_resource_threshold


# -------------------------
# MID
# -------------------------

var mid_surface_materials_noise := FastNoiseLite.new()
var mid_surface_materials_noise_frequency: float = 0.014

var mid_surface_start: int = 0
var mid_surface_end: int = 0

var mid_resource_threshold: float = GLOBALS.mid_ground_resource_threshold


# -------------------------
# MID-DEEP
# -------------------------

var middeep_surface_materials_noise := FastNoiseLite.new()
var middeep_surface_materials_noise_frequency: float = 0.009

var middeep_surface_start: int = 0
var middeep_surface_end: int = 0

var middeep_resource_threshold: float = GLOBALS.middeep_ground_resource_threshold


# -------------------------
# DEEP
# -------------------------

var deep_surface_materials_noise := FastNoiseLite.new()
var deep_surface_materials_noise_frequency: float = 0.005

var deep_surface_start: int = 0
var deep_surface_end: int = 0

var deep_resource_threshold: float = GLOBALS.deep_ground_resource_threshold


# ============================================================
# DEPOSIT PLACEMENT
# ============================================================

# These are TILE distances.
#
# 3 tiles × 16px = 48px minimum distance.
@export var deposit_min_distance: int = 2

# How frequently we search for candidates.
#
# 2 tiles × 16px = 32px candidate spacing.
@export var candidate_spacing: int = 1


# Spatial hash.
# Cell size = minimum deposit distance.
var deposit_grid: Dictionary = {}


# ============================================================
# GENERATED POSITIONS
# ============================================================

@export var low_surface_resource_positions: Array[Dictionary] = []
@export var mid_surface_resource_positions: Array[Dictionary] = []
@export var middeep_surface_resource_positions: Array[Dictionary] = []
@export var deep_surface_resource_positions: Array[Dictionary] = []

var mineral_deposits: Array[Dictionary] = []


# ============================================================
# COUNT ORE
# ============================================================

func count_ore(
	count_dictionary: Dictionary,
	ore_type: GLOBALS.Minerals
) -> void:

	if not count_dictionary.has(ore_type):
		count_dictionary[ore_type] = 0

	count_dictionary[ore_type] += 1


# ============================================================
# GENERATE DEPOSITS
# ============================================================

func find_resource_deposits() -> void:
	var deposit_generator := Deposit_Generator.new()

	# --------------------------------------------------------
	# LOW
	# --------------------------------------------------------

	for x in range(0, map_width, candidate_spacing):

		for y in range(low_surface_start, low_surface_end, candidate_spacing):

			var candidate_position: Vector2i = get_candidate_position(x, y)

			if not is_position_inside_map(candidate_position):
				continue

			var noise_volume_value: float = low_surface_materials_noise.get_noise_2d(
				candidate_position.x,
				candidate_position.y
			)

			var normalized_noise: float = (noise_volume_value + 1.0) * 0.5

			var spawn_chance: float = LOW_SPAWN_CHANCE
			spawn_chance *= lerpf(0.75, 1.25, normalized_noise)

			if rng.randf() > spawn_chance:
				continue

			if not is_deposit_position_available(candidate_position):
				continue

			var ore_deposit: Dictionary = deposit_generator.couple_ore_vein(
				noise_volume_value,
				candidate_position,
				"low",
				low_resource_threshold,
				rng
			)

			if ore_deposit.is_empty():
				continue

			mineral_deposits.append(ore_deposit)
			low_surface_resource_positions.append(ore_deposit)

			count_ore(
				low_ore_counts,
				ore_deposit["type"]
			)

			register_deposit(candidate_position)


	# --------------------------------------------------------
	# MID
	# --------------------------------------------------------

	for x in range(0, map_width, candidate_spacing):

		for y in range(mid_surface_start, mid_surface_end, candidate_spacing):

			var candidate_position: Vector2i = get_candidate_position(x, y)

			if not is_position_inside_map(candidate_position):
				continue

			var noise_volume_value: float = mid_surface_materials_noise.get_noise_2d(
				candidate_position.x,
				candidate_position.y
			)

			var normalized_noise: float = (noise_volume_value + 1.0) * 0.5

			var spawn_chance: float = MID_SPAWN_CHANCE
			spawn_chance *= lerpf(0.75, 1.25, normalized_noise)

			if rng.randf() > spawn_chance:
				continue

			if not is_deposit_position_available(candidate_position):
				continue

			var ore_deposit: Dictionary = deposit_generator.couple_ore_vein(
				noise_volume_value,
				candidate_position,
				"mid",
				mid_resource_threshold,
				rng
			)

			if ore_deposit.is_empty():
				continue

			mineral_deposits.append(ore_deposit)
			mid_surface_resource_positions.append(ore_deposit)

			count_ore(
				mid_ore_counts,
				ore_deposit["type"]
			)

			register_deposit(candidate_position)


	# --------------------------------------------------------
	# MID-DEEP
	# --------------------------------------------------------

	for x in range(0, map_width, candidate_spacing):

		for y in range(middeep_surface_start, middeep_surface_end, candidate_spacing):

			var candidate_position: Vector2i = get_candidate_position(x, y)

			if not is_position_inside_map(candidate_position):
				continue

			var noise_volume_value: float = middeep_surface_materials_noise.get_noise_2d(
				candidate_position.x,
				candidate_position.y
			)

			var normalized_noise: float = (noise_volume_value + 1.0) * 0.5

			var spawn_chance: float = MIDDEEP_SPAWN_CHANCE
			spawn_chance *= lerpf(0.75, 1.25, normalized_noise)

			if rng.randf() > spawn_chance:
				continue

			if not is_deposit_position_available(candidate_position):
				continue

			var ore_deposit: Dictionary = deposit_generator.couple_ore_vein(
				noise_volume_value,
				candidate_position,
				"mid",
				mid_resource_threshold,
				rng
			)

			if ore_deposit.is_empty():
				continue

			mineral_deposits.append(ore_deposit)
			middeep_surface_resource_positions.append(ore_deposit)

			count_ore(
				middeep_ore_counts,
				ore_deposit["type"]
			)

			register_deposit(candidate_position)


	# --------------------------------------------------------
	# DEEP
	# --------------------------------------------------------

	for x in range(0, map_width, candidate_spacing):

		for y in range(deep_surface_start, deep_surface_end, candidate_spacing):

			var candidate_position: Vector2i = get_candidate_position(x, y)

			if not is_position_inside_map(candidate_position):
				continue

			var noise_volume_value: float = deep_surface_materials_noise.get_noise_2d(
				candidate_position.x,
				candidate_position.y
			)

			var normalized_noise: float = (noise_volume_value + 1.0) * 0.5

			var spawn_chance: float = DEEP_SPAWN_CHANCE
			spawn_chance *= lerpf(0.75, 1.25, normalized_noise)

			if rng.randf() > spawn_chance:
				continue

			if not is_deposit_position_available(candidate_position):
				continue

			var ore_deposit: Dictionary = deposit_generator.couple_ore_vein(
				noise_volume_value,
				candidate_position,
				"deep",
				deep_resource_threshold,
				rng
			)
			if ore_deposit.is_empty():
				continue

			mineral_deposits.append(ore_deposit)
			deep_surface_resource_positions.append(ore_deposit)

			count_ore(
				deep_ore_counts,
				ore_deposit["type"]
			)

			register_deposit(candidate_position)


	# ========================================================
	# DEBUG
	# ========================================================

	if debug_messages:

		print("")
		print("========== ORE DISTRIBUTION ==========")

		print("")
		print("MAP:")
		print("  Pixels: ", GLOBALS.map_width, " × ", GLOBALS.map_height)
		print("  Tiles:  ", map_width, " × ", map_height)

		print("")
		print("LAYERS:")
		print("  LOW:      ", low_surface_start, " → ", low_surface_end)
		print("  MID:      ", mid_surface_start, " → ", mid_surface_end)
		print("  MID-DEEP: ", middeep_surface_start, " → ", middeep_surface_end)
		print("  DEEP:     ", deep_surface_start, " → ", deep_surface_end)

		print("")
		print("PLACEMENT:")
		print("  Candidate spacing: ", candidate_spacing, " tiles / ",
			candidate_spacing * GLOBALS.TILE_SIZE, " px")

		print("  Minimum deposit distance: ",
			deposit_min_distance, " tiles / ",
			deposit_min_distance * GLOBALS.TILE_SIZE, " px")

		print("")
		print("LOW:")
		print("  Entivera:   ", low_ore_counts.get(GLOBALS.Minerals.Entivera, 0))
		print("  Barbanium:  ", low_ore_counts.get(GLOBALS.Minerals.Barbanium, 0))
		print("  Rihtocide:  ", low_ore_counts.get(GLOBALS.Minerals.Rihtocide, 0))
		print("  Kviktorium: ", low_ore_counts.get(GLOBALS.Minerals.Kviktorium, 0))

		print("")
		print("MID:")
		print("  Entivera:   ", mid_ore_counts.get(GLOBALS.Minerals.Entivera, 0))
		print("  Barbanium:  ", mid_ore_counts.get(GLOBALS.Minerals.Barbanium, 0))
		print("  Rihtocide:  ", mid_ore_counts.get(GLOBALS.Minerals.Rihtocide, 0))
		print("  Kviktorium: ", mid_ore_counts.get(GLOBALS.Minerals.Kviktorium, 0))

		print("")
		print("MID-DEEP:")
		print("  Entivera:   ", middeep_ore_counts.get(GLOBALS.Minerals.Entivera, 0))
		print("  Barbanium:  ", middeep_ore_counts.get(GLOBALS.Minerals.Barbanium, 0))
		print("  Rihtocide:  ", middeep_ore_counts.get(GLOBALS.Minerals.Rihtocide, 0))
		print("  Kviktorium: ", middeep_ore_counts.get(GLOBALS.Minerals.Kviktorium, 0))

		print("")
		print("DEEP:")
		print("  Entivera:   ", deep_ore_counts.get(GLOBALS.Minerals.Entivera, 0))
		print("  Barbanium:  ", deep_ore_counts.get(GLOBALS.Minerals.Barbanium, 0))
		print("  Rihtocide:  ", deep_ore_counts.get(GLOBALS.Minerals.Rihtocide, 0))
		print("  Kviktorium: ", deep_ore_counts.get(GLOBALS.Minerals.Kviktorium, 0))

		print("")
		print("TOTAL DEPOSITS: ", mineral_deposits.size())

		print("")
		print("======================================")


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	rng.seed = noise_seed

	# --------------------------------------------------------
	# Calculate layer ranges
	# --------------------------------------------------------

	low_surface_start = 0
	low_surface_end = layer_height

	mid_surface_start = max(
		0,
		low_surface_end - layer_overlap
	)
	mid_surface_end = min(
		map_height,
		mid_surface_start + layer_height
	)

	middeep_surface_start = max(
		0,
		mid_surface_end - layer_overlap
	)
	middeep_surface_end = min(
		map_height,
		middeep_surface_start + layer_height
	)

	deep_surface_start = max(
		0,
		middeep_surface_end - layer_overlap
	)
	deep_surface_end = map_height


	# --------------------------------------------------------
	# Noise setup
	# --------------------------------------------------------

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


	# --------------------------------------------------------
	# Generate
	# --------------------------------------------------------

	find_resource_deposits()

	mineral_deposits.shuffle()

	var amount_to_spawn: int = mini(
		35000,
		mineral_deposits.size()
	)

	for i in range(amount_to_spawn):

		var deposit: Dictionary = mineral_deposits[i]
		var coordinates: Vector2i = deposit["coordinates"]

		# If 251 means PIXELS, this should instead be:
		# coordinates.y * GLOBALS.TILE_SIZE > 251
		#
		# Currently 251 means TILE coordinates.
		if coordinates.y * GLOBALS.TILE_SIZE > 251:

			mineral_spawner.initialize_material(
				coordinates,
				deposit["richness"],
				deposit["type"]
			)


# ============================================================
# MAP BOUNDS
# ============================================================

func is_position_inside_map(position: Vector2i) -> bool:

	return (
		position.x >= 0
		and position.x < map_width
		and position.y >= 0
		and position.y < map_height
	)


# ============================================================
# SPATIAL HASH
# ============================================================

func get_grid_cell(position: Vector2i) -> Vector2i:

	return Vector2i(
		floori(float(position.x) / deposit_min_distance),
		floori(float(position.y) / deposit_min_distance)
	)


func is_deposit_position_available(position: Vector2i) -> bool:

	var cell: Vector2i = get_grid_cell(position)

	var minimum_distance_squared: int = (
		deposit_min_distance * deposit_min_distance
	)

	# Check this cell and neighboring cells.
	for offset_x in range(-1, 2):

		for offset_y in range(-1, 2):

			var nearby_cell: Vector2i = (
				cell + Vector2i(offset_x, offset_y)
			)

			if not deposit_grid.has(nearby_cell):
				continue

			for existing_position: Vector2i in deposit_grid[nearby_cell]:

				var difference: Vector2i = (
					position - existing_position
				)

				if difference.length_squared() < minimum_distance_squared:
					return false

	return true


func register_deposit(position: Vector2i) -> void:

	var cell: Vector2i = get_grid_cell(position)

	if not deposit_grid.has(cell):
		deposit_grid[cell] = []

	deposit_grid[cell].append(position)


# ============================================================
# CANDIDATE POSITION
# ============================================================

func get_candidate_position(x: int, y: int) -> Vector2i:

	var half_spacing: int = candidate_spacing / 2

	var candidate_x: int = (
		x + rng.randi_range(-half_spacing, half_spacing)
	)

	var candidate_y: int = (
		y + rng.randi_range(-half_spacing, half_spacing)
	)

	return Vector2i(
		candidate_x,
		candidate_y
	)


# ============================================================
# PROCESS
# ============================================================

func _process(_delta: float) -> void:
	pass
