extends Node2D
class_name MineralSpawner
var mineral_types = GLOBALS.Minerals
@onready var ore_2d: Sprite2D = $Ore2D
const MINERAL_ORE = preload("uid://m28neimafqeu")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

@export var tile_size: int = 16

func initialize_material(coordinates: Vector2i, richness: float):
	var mineral: MineralOre = MINERAL_ORE.instantiate()
	mineral.amount = richness * 100
	mineral.position = Vector2(coordinates) * tile_size
	get_parent().add_child(mineral)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
