extends TileMapLayer

@export var repetitions := 20


func _ready():
	var cells: Array[Vector2i] = []

	for y in range(70):
		cells.append(Vector2i(0, y))
		cells.append(Vector2i(1, y))

	var pattern := get_pattern(cells)

	# Left
	for i in range(1, repetitions + 1):
		set_pattern(Vector2i(-i * 2, 0), pattern)

	# Right
	for i in range(1, repetitions + 1):
		set_pattern(Vector2i(i * 2, 0), pattern)
