
extends Node2D
class_name MineralSpawner

const MINERAL_ORE = preload("uid://m28neimafqeu")

@export var tile_size: int = 16
@export var ore_scale: float = 0.5


func initialize_material(
	coordinates: Vector2i,
	richness: float,
	mineral_type: GLOBALS.Minerals
) -> void:
	var mineral: MineralOre = MINERAL_ORE.instantiate()

	# Add it first so its transform is relative to the correct parent.
	get_parent().add_child(mineral)

	# Convert tile coordinates -> pixel coordinates.
	mineral.position = Vector2(coordinates) * tile_size

	# Set amount.
	mineral.amount = richness * 100.0

	# Get the ore sprite.
	var sprite: Sprite2D = mineral.get_node("Sprite2D")
	sprite.scale = Vector2.ONE * ore_scale

	# Set texture.
	match mineral_type:
		GLOBALS.Minerals.Entivera:
			sprite.texture = preload("res://assets/textures/ore_1.svg")

		GLOBALS.Minerals.Barbanium:
			sprite.texture = preload("res://assets/textures/ore_2.svg")

		GLOBALS.Minerals.Rihtocide:
			sprite.texture = preload("res://assets/textures/ore_3.svg")

		GLOBALS.Minerals.Kviktorium:
			sprite.texture = preload("res://assets/textures/ore_1.svg")

		_:
			print("Unknown mineral")
