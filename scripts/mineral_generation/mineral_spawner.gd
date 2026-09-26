extends Node2D
class_name MineralSpawner
var mineral_types = GLOBALS.Minerals
@onready var ore_2d: Sprite2D = $Ore2D
const MINERAL_ORE = preload("uid://m28neimafqeu")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

@export var tile_size: int = 16

func initialize_material(coordinates: Vector2i, richness: float, mineral_type: GLOBALS.Minerals):
	var mineral: MineralOre = MINERAL_ORE.instantiate()
	mineral.amount = richness * 100
	mineral.position = Vector2(coordinates) * tile_size
	match mineral_type:
		GLOBALS.Minerals.Entivera:
			var sprite: Sprite2D = mineral.get_node("Sprite2D")
			sprite.texture = preload("res://assets/textures/ore_1.svg")

		GLOBALS.Minerals.Barbanium:
			var sprite: Sprite2D = mineral.get_node("Sprite2D")
			sprite.texture = preload("res://assets/textures/ore_2.svg")
			
		GLOBALS.Minerals.Rihtocide:
			var sprite: Sprite2D = mineral.get_node("Sprite2D")
			sprite.texture = preload("res://assets/textures/ore_3.svg")
			
		GLOBALS.Minerals.Kviktorium:
			var sprite: Sprite2D = mineral.get_node("Sprite2D")
			sprite.texture = preload("res://assets/textures/ore_1.svg")

		_:
			print("Unknown mineral")

	get_parent().add_child(mineral)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
