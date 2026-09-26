extends Node

var points:int 
var score:int

var map_width: int = 10500
var map_height: int = 9000
const TILE_SIZE: int = 16

var map_width_tiles: int = map_width / TILE_SIZE
var map_height_tiles: int = map_height / TILE_SIZE


var low_ground_resource_threshold: float = 0.30
var mid_ground_resource_threshold: float = 0.32
var middeep_ground_resource_threshold: float = 0.34
var deep_ground_resource_threshold: float = 0.36

var minerals_range = {
	Minerals.Entivera : { "min": 0.46, "max": 0.50 },
	Minerals.Barbanium : {"min": 0.50, "max": 0.56 },
	Minerals.Rihtocide : {"min": 0.56, "max": 0.61 },
	Minerals.Kviktorium : {"min": 0.61, "max": 0.75 }
}

var mineral_depth_weights = {
	Minerals.Entivera: {
		"low": 100.0,
		"mid": 35.0,
		"middeep": 5.0,
		"deep": 0.0
	},

	Minerals.Barbanium: {
		"low": 10.0,
		"mid": 100.0,
		"middeep": 30.0,
		"deep": 0.0
	},

	Minerals.Rihtocide: {
		"low": 0.0,
		"mid": 20.0,
		"middeep": 100.0,
		"deep": 30.0
	},

	Minerals.Kviktorium: {
		"low": 0.0,
		"mid": 0.0,
		"middeep": 5.0,
		"deep": 100.0
	}
}


enum Minerals {
		None,
		Entivera, # Most common
		Barbanium, # Rare
		Rihtocide, # Very rare
		Kviktorium, # Rarest
	}
