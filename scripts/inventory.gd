extends Node2D

enum MineralTypes {ENTIVERA, BARBANIUM, RIHTOCIDE, KVIKTORIUM}

var minerals = {
	MineralTypes.ENTIVERA: 50,
	MineralTypes.BARBANIUM: 40,
	MineralTypes.RIHTOCIDE: 30,
	MineralTypes.KVIKTORIUM: 20
}

func _ready() -> void:
	make_transaction(MineralTypes.ENTIVERA, 40)
	print(minerals.get(MineralTypes.ENTIVERA))

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
