extends Node2D
class_name MineralOre

signal material_mined(mineral_type: GLOBALS.Minerals, amount: int)

var mineral_type: GLOBALS.Minerals

@export var mining_radius = 25

var damage_dealt: int
var amount: int
var coordinates: Vector2i
var depleted := false

func _ready() -> void:
	match mineral_type:
		GLOBALS.Minerals.Entivera:
			damage_dealt = 5;
		GLOBALS.Minerals.Barbanium:
			damage_dealt = 10;
		GLOBALS.Minerals.Rihtocide:
			damage_dealt = 20;
		GLOBALS.Minerals.Kviktorium:
			damage_dealt = 50;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func mine_material(mined_amount: int) -> void:
	var actual_amount_mined
	if amount - mined_amount <= 0:
		actual_amount_mined = amount
		amount = 0;
		depleted = true
		material_mined.emit(mineral_type, actual_amount_mined)
	else:
		amount -= mined_amount
		material_mined.emit(mineral_type, mined_amount)
	print("MINERAL ORE: MINED & REMAINING: " + str(amount))
