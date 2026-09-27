extends Node2D
class_name Obstacle

enum ObstacleType {
	CLAY,
	ROCK
}

@onready var sprite: Sprite2D = $Sprite
@export var rock_texture:Texture2D
@export var clay_texture:Texture2D

@export var type: ObstacleType = ObstacleType.CLAY
@export var coordinates: Vector2i

var damage_dealt: int
var strength: float
var depleted := false

func setup(obs_type: ObstacleType, coords: Vector2i) -> void:
	type = obs_type
	coordinates = coords

	strength = 1.0
	depleted = false

	match type:
		ObstacleType.CLAY:
			damage_dealt = 5
			sprite.texture = clay_texture
		ObstacleType.ROCK:
			damage_dealt = 10
			sprite.texture = rock_texture

	global_position = Vector2(coords)
