extends Node
class_name Deposit_Generator


var Minerals = GLOBALS.Minerals
var minerals_range: Dictionary = GLOBALS.minerals_range
var mineral_depth_weights: Dictionary = GLOBALS.mineral_depth_weights


func define_mineral_type(
	depth_layer: String,
	rng: RandomNumberGenerator
) -> GLOBALS.Minerals:

	var total_weight: float = 0.0

	# Calculate total weight for this depth.
	for mineral in Minerals.values():

		if mineral == Minerals.None:
			continue

		var mineral_weights: Dictionary = mineral_depth_weights[mineral]
		var weight: float = mineral_weights[depth_layer]

		total_weight += weight


	if total_weight <= 0.0:
		return Minerals.None


	# Random number between 0 and total weight.
	var roll: float = rng.randf_range(
		0.0,
		total_weight
	)

	var accumulated_weight: float = 0.0

	for mineral in Minerals.values():

		if mineral == Minerals.None:
			continue

		var mineral_weights: Dictionary = mineral_depth_weights[mineral]
		var weight: float = mineral_weights[depth_layer]

		if weight <= 0.0:
			continue

		accumulated_weight += weight

		if roll <= accumulated_weight:
			return mineral


	return Minerals.None


func define_material_richness(
	volume_noise_value: float,
	threshold: float
) -> float:

	var richness: float = inverse_lerp(
		threshold,
		0.75,
		volume_noise_value
	)

	return clampf(richness, 0.0, 1.0)


func couple_ore_vein(
	volume_noise_value: float,
	coordinates: Vector2i,
	depth_layer: String,
	threshold: float,
	rng: RandomNumberGenerator
) -> Dictionary:

	var mineral_type: GLOBALS.Minerals = define_mineral_type(
		depth_layer,
		rng
	)

	if mineral_type == Minerals.None:
		return {}


	var mineral_richness: float = define_material_richness(
		volume_noise_value,
		threshold
	)


	return {
		"coordinates": coordinates,
		"noise_volume": volume_noise_value,
		"type": mineral_type,
		"richness": mineral_richness
	}
