extends Node2D

signal mineral_amount_changed(minerals)

var minerals = {
	GLOBALS.Minerals.Entivera: 0,
	GLOBALS.Minerals.Barbanium: 0,
	GLOBALS.Minerals.Rihtocide: 0,
	GLOBALS.Minerals.Kviktorium: 0
}

func _ready() -> void:
	pass


func get_minerals():
	return minerals

func check_transaction(type:GLOBALS.Minerals, amount:int):
	if minerals.get(type) < amount:
		return false;
	return true;


func make_transaction(type:GLOBALS.Minerals, amount:int):
	if !check_transaction(type, amount):
		return
	minerals.set(type, minerals.get(type) - amount)


func add_funds(type:GLOBALS.Minerals, amount:int):
	minerals.set(type, minerals.get(type) + amount)
	mineral_amount_changed.emit(minerals)
	print("[Inventory] Added: " + str(amount) + " to " + str(type))


func _on_skill_tree_upgrade_purchased(entivera: int, barbarium: int, rihtocide: int, kviktorium: int) -> void:
	make_transaction(GLOBALS.Minerals.Entivera, entivera)
	make_transaction(GLOBALS.Minerals.Barbanium, barbarium)
	make_transaction(GLOBALS.Minerals.Rihtocide, rihtocide)
	make_transaction(GLOBALS.Minerals.Kviktorium, kviktorium)
	mineral_amount_changed.emit(minerals)
