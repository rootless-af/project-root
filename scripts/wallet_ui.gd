extends Control

@onready var entivera_label: Label = $TextureRect/Entivera
@onready var barbanium_label: Label = $TextureRect2/Barbanium
@onready var rihtocide_label: Label = $TextureRect3/Rihtocide
@onready var kviktorium_label: Label = $TextureRect4/Kviktorium


func _ready() -> void:
	update_amounts({
		GLOBALS.Minerals.Entivera: 0,
		GLOBALS.Minerals.Barbanium: 0,
		GLOBALS.Minerals.Rihtocide: 0,
		GLOBALS.Minerals.Kviktorium: 0
	})

func update_amounts(minerals: Dictionary) -> void:
	entivera_label.text = str(minerals.get(GLOBALS.Minerals.Entivera, 0))
	barbanium_label.text = str(minerals.get(GLOBALS.Minerals.Barbanium, 0))
	rihtocide_label.text = str(minerals.get(GLOBALS.Minerals.Rihtocide, 0))
	kviktorium_label.text = str(minerals.get(GLOBALS.Minerals.Kviktorium, 0))

func _on_inventory_mineral_amount_changed(minerals: Variant) -> void:
	update_amounts(minerals)
