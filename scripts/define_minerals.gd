extends Node
class_name  Deposit_Generator
	
var Minerals = GLOBALS.Minerals

var minerals_range = GLOBALS.minerals_range


func define_mineral_type(volume_noise_value: float) -> GLOBALS.Minerals :
	for mineral in minerals_range:
		var range_data: Dictionary = minerals_range[mineral]
		if (volume_noise_value >= range_data.min and volume_noise_value < range_data.max):
			return mineral
			
	return Minerals.None
			
			
func define_material_richness(volume_noise_value: float, limit: float, threshold: float) :
	var richness = inverse_lerp(threshold, limit, volume_noise_value)
	
	return richness
	
func couple_ore_vein(volume_noise_value: float, coordinates: Vector2i):
	var mineral_type: GLOBALS.Minerals = define_mineral_type(volume_noise_value)
	var mineral_richness: float = 0.0
	
	if mineral_type == Minerals.None :
		return {}
		 
	mineral_richness = define_material_richness(volume_noise_value, minerals_range[mineral_type].max, minerals_range[mineral_type].min)
	return {"coordinates": coordinates, "noise_volume": volume_noise_value, "type": mineral_type, "richness": mineral_richness}
