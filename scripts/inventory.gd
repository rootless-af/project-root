extends Node2D

enum MineralTypes {ENTIVERA, BARBANIUM, RIHTOCIDE, KVIKTORIUM}

var materials = {
	MineralTypes.ENTIVERA: 50,
	MineralTypes.BARBANIUM: 40,
	MineralTypes.RIHTOCIDE: 30,
	MineralTypes.KVIKTORIUM: 20
}

func _ready() -> void:
	print(check_transaction(MineralTypes.ENTIVERA, 50))

func check_transaction(type:MineralTypes, amount:int):
	if materials.get(MineralTypes.ENTIVERA) < amount:
		return false;
	return true;
	
