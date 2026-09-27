extends Node

var points:int 
var score:int

var map_width = 10000
var map_height = 19000

var low_ground_resource_threshold: float = 0.42
var mid_ground_resource_threshold: float = 0.50
var middeep_ground_resource_threshold: float = 0.56
var deep_ground_resource_threshold: float = 0.61

var minerals_range = {
	Minerals.Entivera : { "min": 0.420000, "max": 0.549999 },
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

enum Levels {
	LOW_LEVEL,
	MID_LEVEL,
	MID_DEEP_LEVEL,
	DEEP_LEVEL,
	CORE
}

var level_depths = {
	Levels.LOW_LEVEL: 0,
	Levels.MID_LEVEL: 2650,
	Levels.MID_DEEP_LEVEL: 4900,
	Levels.DEEP_LEVEL: 7050,
	Levels.CORE: 9150,
}


enum SkillTreeUpgrades {
	BRANCH_ABILITY,
	ANGLE_UPGRADE,
	STRAIGHTEN_UPGRADE,
	WIDTH_UPGRADE,
	BRANCHING_TIPS_UPGRADE,
	BRANCHING_CHANCE_UPGRADE,
	GROWTH_DEPTH_UPGRADE,
	GATHER_SPEED_UPGRADE,
	GATHER_AMOUNT_UPGRADE,
	PENETRATE_CLAY_ABILITY,
	PENETRATE_CLAY_SPEED_UPGRADE,
	PENETRATE_ROCK_ABILITY,
	PENETRATE_ROCK_SPEED_UPGRADE
}
