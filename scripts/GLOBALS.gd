extends Node

var points:int 
var score:int
const TILE_SIZE: int = 16

var map_width = 10000 / TILE_SIZE
var map_height = 17000 / TILE_SIZE

var low_ground_resource_threshold: float = 0.49
var low_ground_resource_start: int = 0
var low_ground_resource_end: int = 0

var mid_ground_resource_threshold: float = 0.54
var mid_ground_resource_start: int = 0
var mid_ground_resource_end: int =0

var middeep_ground_resource_threshold: float = 0.56
var middeep_ground_resource_start: int =0
var middeep_ground_resource_end: int = 0

var deep_ground_resource_threshold: float = 0.61
var deep_ground_resource_start: int =0
var deep_ground_resource_end: int =0

var minerals_range = {
	Minerals.Entivera : { "min": 0.49, "max": 0.50 },
	Minerals.Barbanium : {"min": 0.54, "max": 0.56 },
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
