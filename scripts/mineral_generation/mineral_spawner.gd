extends Node2D
class_name MineralSpawner

signal minerals_initialized(minerals:Array[MineralOre])

var mineral_types = GLOBALS.Minerals
const MINERAL_ORE = preload("uid://m28neimafqeu")
var minerals:Array[MineralOre] = []
@onready var inventory: Node2D = $"../Inventory"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Test Purposes
	var minerals: Array[MineralData] = []
	var mineral1 := MineralData.new()
	var coords = Vector2i(500, 250)
	mineral1.init(coords, 0.5, GLOBALS.Minerals.Entivera)
	minerals.append(mineral1)
	initialize_minerals(minerals)

@export var tile_size: int = 16

func initialize_minerals(data: Array[MineralData]) -> void:
	var new_minerals: Array[MineralOre] = []
	for mineral_data in data:
		var mineral: MineralOre = MINERAL_ORE.instantiate()
		mineral.amount = int(mineral_data.richness * 100)
		mineral.coordinates = mineral_data.coordinates
		mineral.position = Vector2(mineral_data.coordinates)
		mineral.mineral_type = mineral_data.mineral_type
		mineral.material_mined.connect(_on_material_mined)
		add_child(mineral)
		new_minerals.append(mineral)
	minerals = new_minerals
	minerals_initialized.emit(minerals)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_material_mined(mineral_type: GLOBALS.Minerals, amount: int) -> void:
	inventory.add_funds(mineral_type, amount)


class MineralData:
	var coordinates:Vector2i
	var richness: float
	var mineral_type: GLOBALS.Minerals
	
	func init(coords, richness, type):
		coordinates = coords
		self.richness = richness
		self.mineral_type = type
		return self
		
