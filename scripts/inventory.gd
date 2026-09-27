extends Node2D

signal mineral_amount_changed(minerals)

var minerals = {
	GLOBALS.Minerals.Entivera: 0,
	GLOBALS.Minerals.Barbanium: 0,
	GLOBALS.Minerals.Rihtocide: 0,
	GLOBALS.Minerals.Kviktorium: 0
}

func _ready() -> void:
	mineral_amount_changed.emit(minerals)


func get_minerals():
	return minerals

func can_afford(cost: Dictionary) -> bool:
	for type in cost:
		if minerals.get(type, 0) < cost[type]:
			return false
	
	return true



func check_transaction(type:GLOBALS.Minerals, amount:int):
	if minerals.get(type) < amount:
		return false;
	return true;


func make_transaction(cost: Dictionary) -> bool:
	if not can_afford(cost):
		return false
	
	for type in cost:
		minerals[type] -= cost[type]
	
	mineral_amount_changed.emit(minerals)
	return true


func add_funds(type:GLOBALS.Minerals, amount:int):
	minerals.set(type, minerals.get(type) + amount)
	mineral_amount_changed.emit(minerals)
	print("[Inventory] Added: " + str(amount) + " to " + str(type))


func _on_skill_tree_upgrade_purchased(
	entivera: int,
	barbarium: int,
	rihtocide: int,
	kviktorium: int
) -> void:
	var cost := {
		GLOBALS.Minerals.Entivera: entivera,
		GLOBALS.Minerals.Barbanium: barbarium,
		GLOBALS.Minerals.Rihtocide: rihtocide,
		GLOBALS.Minerals.Kviktorium: kviktorium
	}
	
	if make_transaction(cost):
		print("[Inventory] Skill tree upgrade purchased")
