extends Node2D

signal mineral_amount_changed(minerals)
enum MineralTypes {ENTIVERA, BARBANIUM, RIHTOCIDE, KVIKTORIUM}

var minerals = {
	MineralTypes.ENTIVERA: 0,
	MineralTypes.BARBANIUM: 0,
	MineralTypes.RIHTOCIDE: 0,
	MineralTypes.KVIKTORIUM: 0
}

func _ready() -> void:
	make_transaction(MineralTypes.ENTIVERA, 40)


func get_minerals():
	return minerals

func check_transaction(type:MineralTypes, amount:int):
	if minerals.get(MineralTypes.ENTIVERA) < amount:
		return false;
	return true;


func make_transaction(type:MineralTypes, amount:int):
	if !check_transaction(type, amount):
		return
	minerals.set(type, minerals.get(type) - amount)


func add_funds(type:MineralTypes, amount:int):
	minerals.set(type, minerals.get(type) + amount)
	mineral_amount_changed.emit(minerals)


func _on_skill_tree_upgrade_purchased(entivera: int, barbarium: int, rihtocide: int, kviktorium: int) -> void:
	make_transaction(MineralTypes.ENTIVERA, entivera)
	make_transaction(MineralTypes.BARBANIUM, barbarium)
	make_transaction(MineralTypes.RIHTOCIDE, rihtocide)
	make_transaction(MineralTypes.KVIKTORIUM, kviktorium)
	mineral_amount_changed.emit(minerals)
