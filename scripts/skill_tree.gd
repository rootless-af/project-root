extends Node2D
signal mineral_amount_changed(minerals)
signal upgrade_purchased(entivera:int, barbarium:int, rihtocide:int, kviktorium:int)

#@onready var inventory: Node2D = $"../Inventory"

const UPGRADE = preload("uid://cx4b27672a2ps")
const ROOT = preload("uid://d1pn0awo34ut7")

var root_instance = null;
var root = null;

func _ready() -> void:
	
	root_instance = ROOT.instantiate()
	root_instance.max_active_tips = 1
	root_instance.root_width = 50
<<<<<<< HEAD
=======
	root_instance.growth_speed = 200
>>>>>>> e930231304864a6cc72b17cafc36588fdb938dfc
	root_instance.max_depth = 1000
	root_instance.min_depth = 500


func apply_upgrade(upgrade_type:Resource):
	var upgrade:Upgrade = UPGRADE.instantiate()
	upgrade.upgrade_base = upgrade_type
	test_upgrade(upgrade)


func test_upgrade(upgrade:Upgrade):
	root_instance.add_child(upgrade)

func _on_test_start_button_pressed() -> void:
	if root == null:
		root = root_instance.duplicate()
		root.position += Vector2(500, 0)
		get_parent().add_child(root)


func _on_test_stop_button_pressed() -> void:
	if root != null:
		root.queue_free()
		root = null;

func _on_inventory_mineral_amount_changed(minerals) -> void:
	mineral_amount_changed.emit(minerals)


func _on_growth_upgrade_upgrade_purchased(upgrade_with_cost: UpgradeWithCosts) -> void:
	apply_upgrade(upgrade_with_cost.upgrade_type)
	upgrade_purchased.emit(
		upgrade_with_cost.entivera,
		upgrade_with_cost.barbanium, 
		upgrade_with_cost.rihtocide, 
		upgrade_with_cost.kviktorium
	)
	
