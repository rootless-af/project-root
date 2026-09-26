extends Node

var points:int 
var score:int

var map_width = 10000
var map_height = 19000

var low_ground_resource_threshold: float = 0.46
var mid_ground_resource_threshold: float = 0.50
var middeep_ground_resource_threshold: float = 0.56
var deep_ground_resource_threshold: float = 0.61

var minerals_range = {
	Minerals.Entivera : { "min": 0.46, "max": 0.50 },
	Minerals.Barbanium : {"min": 0.50, "max": 0.56 },
	Minerals.Rihtocide : {"min": 0.56, "max": 0.61 },
	Minerals.Kviktorium : {"min": 0.61, "max": 0.75 }
}

enum Minerals {
		None,
		Entivera, # Most common
		Barbanium, # Rare
		Rihtocide, # Very rare
		Kviktorium, # Rarest
	}
