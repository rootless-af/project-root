
extends Node2D
class_name MineralSpawner

signal minerals_initialized(minerals: Array[MineralOre])
signal obstacles_initialized(obstacles: Array[Obstacle])

var mineral_types = GLOBALS.Minerals
var next_obstacle: int
const MINERAL_ORE = preload("uid://m28neimafqeu")
const OBSTACLE = preload("uid://ktc6e14lkvxc")

var minerals: Array[MineralOre] = []
var obstacles: Array[Obstacle] = []

@onready var inventory: Node2D = $"../Inventory"
@export var tile_size: int = 16
@export var ore_scale: float = 0.5

func _ready() -> void:
	pass


func initialize_minerals(data: Array[MineralData]) -> void:
	# Clear old references.
	minerals.clear()
	obstacles.clear()

	var new_minerals: Array[MineralOre] = []
	var new_obstacles: Array[Obstacle] = []

	# Reset obstacle spacing each time we generate the layer.
	next_obstacle = randi_range(7, 10)

	for i in range(data.size()):
		var material_data := data[i]

		# Spawn an obstacle at this position.
		if i >= next_obstacle:
			var obstacle := generate_obstacle(
				material_data.coordinates
			)

			new_obstacles.append(obstacle)

			next_obstacle += randi_range(7, 10)
			continue

		# Create mineral.
		var mineral: MineralOre = MINERAL_ORE.instantiate()

		mineral.amount = int(material_data.richness * 100)
		mineral.coordinates = material_data.coordinates
		mineral.global_position = Vector2(material_data.coordinates)
		mineral.mineral_type = material_data.mineral_type

		mineral.material_mined.connect(_on_material_mined)
		mineral.tree_exited.connect(_on_mineral_removed.bind(mineral))

		add_child(mineral)
		new_minerals.append(mineral)

	minerals = new_minerals
	obstacles = new_obstacles

	minerals_initialized.emit(minerals)
	obstacles_initialized.emit(obstacles)


func generate_obstacle(coordinates: Vector2i) -> Obstacle:
	var obstacle: Obstacle = OBSTACLE.instantiate()

	var obstacle_type: Obstacle.ObstacleType

	if randf() < 0.5:
		obstacle_type = Obstacle.ObstacleType.CLAY
	else:
		obstacle_type = Obstacle.ObstacleType.ROCK

	add_child(obstacle)

	obstacle.setup(
		obstacle_type,
		coordinates
	)

	obstacle.tree_exited.connect(
		_on_obstacle_removed.bind(obstacle)
	)

	return obstacle


func _on_material_mined(
	mineral_type: GLOBALS.Minerals,
	amount: int
) -> void:
	inventory.add_funds(
		mineral_type,
		amount
	)


func _on_mineral_removed(mineral: MineralOre) -> void:
	minerals.erase(mineral)


func _on_obstacle_removed(obstacle: Obstacle) -> void:
	obstacles.erase(obstacle)


func _process(_delta: float) -> void:
	pass


class MineralData:
	var coordinates: Vector2i
	var richness: float
	var mineral_type: GLOBALS.Minerals

	func init(
		coords: Vector2i,
		richness_value: float,
		type: GLOBALS.Minerals
	) -> MineralData:
		coordinates = coords
		richness = richness_value
		mineral_type = type

		return self
