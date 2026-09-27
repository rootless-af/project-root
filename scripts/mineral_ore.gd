extends Node2D
class_name MineralOre

signal material_mined(mineral_type: GLOBALS.Minerals, amount: int)

var mineral_type: GLOBALS.Minerals

@onready var sprite: Sprite2D = $Sprite2D

@export var mining_radius := 25

@export var entivera_texture: Texture2D
@export var barbanium_texture: Texture2D
@export var rihtoice_texture: Texture2D
@export var kviktorium_texture: Texture2D

# 75% texture
@export var entivera_texture_75: Texture2D
@export var barbanium_texture_75: Texture2D
@export var rihtoice_texture_75: Texture2D
@export var kviktorium_texture_75: Texture2D

# 35% texture
@export var entivera_texture_35: Texture2D
@export var barbanium_texture_35: Texture2D
@export var rihtoice_texture_35: Texture2D
@export var kviktorium_texture_35: Texture2D

var damage_dealt: int
var amount: int
const MAX_AMOUNT := 100
var coordinates: Vector2i
var depleted := false


func _ready() -> void:

	match mineral_type:
		GLOBALS.Minerals.Entivera:
			damage_dealt = 5

		GLOBALS.Minerals.Barbanium:
			damage_dealt = 10

		GLOBALS.Minerals.Rihtocide:
			damage_dealt = 20

		GLOBALS.Minerals.Kviktorium:
			damage_dealt = 50
	update_texture()


func mine_material(mined_amount: int) -> void:
	var actual_amount_mined: int

	if amount - mined_amount <= 0:
		actual_amount_mined = amount
		amount = 0
		depleted = true
	else:
		amount -= mined_amount
		actual_amount_mined = mined_amount

	material_mined.emit(mineral_type, actual_amount_mined)
	print("MINERAL ORE: MINED & REMAINING: ", amount)
	update_texture()

	


func update_texture() -> void:
	if MAX_AMOUNT <= 0:
		return

	var percentage := float(amount) / float(MAX_AMOUNT)

	match mineral_type:
		GLOBALS.Minerals.Entivera:
			if percentage > 0.75:
				sprite.texture = entivera_texture
			elif percentage > 0.35:
				sprite.texture = entivera_texture_75
			else:
				sprite.texture = entivera_texture_35

		GLOBALS.Minerals.Barbanium:
			if percentage > 0.75:
				sprite.texture = barbanium_texture
			elif percentage > 0.35:
				sprite.texture = barbanium_texture_75
			else:
				sprite.texture = barbanium_texture_35

		GLOBALS.Minerals.Rihtocide:
			if percentage > 0.75:
				sprite.texture = rihtoice_texture
			elif percentage > 0.35:
				sprite.texture = rihtoice_texture_75
			else:
				sprite.texture = rihtoice_texture_35

		GLOBALS.Minerals.Kviktorium:
			if percentage > 0.75:
				sprite.texture = kviktorium_texture
			elif percentage > 0.35:
				sprite.texture = kviktorium_texture_75
			else:
				sprite.texture = kviktorium_texture_35


func _on_area_2d_mouse_entered() -> void:
	print(coordinates)
