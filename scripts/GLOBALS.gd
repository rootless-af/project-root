extends Node

var points:int 
var score:int

var map_width = 5000
var map_height = 5000

var low_ground_resource_threshold: float = 0.49
var mid_ground_resource_threshold: float = 0.36
var middeep_ground_resource_threshold: float = 0.29
var deep_ground_resource_threshold: float = 0.21

var minerals_range = {
	Minerals.Entivera : { "min": 0.490000, "max": 0.549999 },
	Minerals.Barbanium : {"min": 0.550000, "max": 0.570000 },
	Minerals.Rihtocide : {"min": 0.36000, "max": 0.420000 },
	Minerals.Kviktorium : {"min": 0.21000, "max": 0.27000 }
}

enum Minerals {
		None,
		Entivera, # Most common
		Barbanium, # Rare
		Rihtocide, # Very rare
		Kviktorium, # Rarest
	}
