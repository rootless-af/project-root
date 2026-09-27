extends Node2D
signal mineral_amount_changed(minerals)
signal upgrade_purchased(entivera:int, barbarium:int, rihtocide:int, kviktorium:int)
signal appled_upgrade(upgrade:Upgrade, tree_name:String)


#@onready var inventory: Node2D = $"../Inventory"

@onready var branch_ability: SkillTreeButton = $BranchAbility
@onready var angle_upgrade: SkillTreeButton = $AngleUpgrade
@onready var straighten_upgrade: SkillTreeButton = $StraightenUpgrade
@onready var width_upgrade: SkillTreeButton = $WidthUpgrade
@onready var branching_tips_upgrade: SkillTreeButton = $BranchingTipsUpgrade
@onready var branching_chance_upgrade: SkillTreeButton = $BranchingChanceUpgrade
@onready var growth_depth_upgrade: SkillTreeButton = $GrowthDepthUpgrade
@onready var gather_amount_upgrade: SkillTreeButton = $GatherAmountUpgrade
@onready var gather_speed_upgrade: SkillTreeButton = $GatherSpeedUpgrade
@onready var penetrate_clay_ability: SkillTreeButton = $PenetrateClayAbility
@onready var penetrate_clay_speed_upgrade: SkillTreeButton = $PenetrateClaySpeedUpgrade
@onready var penetrate_rock_ability: SkillTreeButton = $PenetrateRockAbility
@onready var penetrate_rock_speed_upgrade: SkillTreeButton = $PenetrateRockSpeedUpgrade
@onready var label: Label = $Label

@export var tree_name:String

const UPGRADE = preload("uid://cx4b27672a2ps")
const ROOT = preload("uid://d1pn0awo34ut7")

var root_instance = null;
var root = null;

func _ready() -> void:
	label.text = tree_name
	penetrate_rock_ability.disable(true)
	penetrate_clay_speed_upgrade.disable(true)
	penetrate_rock_speed_upgrade.disable(true)
	growth_depth_upgrade.disable(true)
	width_upgrade.disable(true)
	branching_chance_upgrade.disable(true)
	branching_tips_upgrade.disable(true)
	
	branch_ability.upgrade_completed.connect(_on_branch_ability_completed)
	angle_upgrade.upgrade_completed.connect(_on_angle_completed)
	straighten_upgrade.upgrade_completed.connect(_on_straighten_completed)

	angle_upgrade.upgrade_started.connect(_on_angle_started)
	straighten_upgrade.upgrade_started.connect(_on_straighten_started)

	penetrate_clay_ability.upgrade_completed.connect(_on_penetrate_clay_completed)
	penetrate_rock_ability.upgrade_completed.connect(_on_penetrate_rock_completed)
	
	root_instance = ROOT.instantiate()
	root_instance.max_active_tips = 1
	root_instance.root_width = 50
	root_instance.growth_speed = 200
	root_instance.max_depth = 1000
	root_instance.min_depth = 500
	root_instance.growth_speed = 800
	root_instance.rock_penetration = 0.15
	root_instance.clay_penetration = 0.15


	branch_ability.upgrade_purchased.connect(_on_upgrade_purchased)
	angle_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)
	straighten_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)
	width_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)
	branching_tips_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)
	branching_chance_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)
	growth_depth_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)
	gather_amount_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)
	gather_speed_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)
	penetrate_clay_ability.upgrade_purchased.connect(_on_upgrade_purchased)
	penetrate_clay_speed_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)
	penetrate_rock_ability.upgrade_purchased.connect(_on_upgrade_purchased)
	penetrate_rock_speed_upgrade.upgrade_purchased.connect(_on_upgrade_purchased)


func apply_upgrade(upgrade_type:Resource):
	var upgrade:Upgrade = UPGRADE.instantiate()
	upgrade.upgrade_base = upgrade_type
	appled_upgrade.emit(upgrade, tree_name)


func test_upgrade(upgrade:Upgrade):
	root_instance.add_child(upgrade)

func _on_test_start_button_pressed() -> void:
	if root == null:
		root = root_instance.duplicate()
		root.set_minerals(root_instance.minerals)
		root.set_obstacles(root_instance.obstacles)
		root.position += Vector2(500, 0)
		get_parent().add_child(root)


func _on_test_stop_button_pressed() -> void:
	if root != null:
		root.queue_free()
		root = null;

func _on_inventory_mineral_amount_changed(minerals) -> void:
	mineral_amount_changed.emit(minerals)


func _on_upgrade_purchased(upgrade_with_cost: UpgradeWithCosts) -> void:
	apply_upgrade(upgrade_with_cost.upgrade_type)

	upgrade_purchased.emit(
		upgrade_with_cost.entivera,
		upgrade_with_cost.barbanium,
		upgrade_with_cost.rihtocide,
		upgrade_with_cost.kviktorium
	)

func _on_branch_ability_completed() -> void:
	branching_chance_upgrade.disable(false)
	branching_tips_upgrade.disable(false)
	growth_depth_upgrade.disable(false)


func _on_angle_completed() -> void:
	straighten_upgrade.disable(true)
	width_upgrade.disable(false)


func _on_straighten_completed() -> void:
	angle_upgrade.disable(true)
	width_upgrade.disable(false)

func _on_angle_started() -> void:
	straighten_upgrade.disable(true)


func _on_straighten_started() -> void:
	angle_upgrade.disable(true)


func _on_penetrate_clay_completed() -> void:
	penetrate_clay_speed_upgrade.disable(false)
	penetrate_rock_ability.disable(false)

func _on_penetrate_rock_completed() -> void:
	penetrate_rock_speed_upgrade.disable(false)


func _on_mineral_spawner_minerals_initialized(minerals: Array[MineralOre]) -> void:
	root_instance.set_minerals(minerals)


func _on_mineral_spawner_obstacles_initialized(obstacles: Array[Obstacle]) -> void:
	root_instance.set_obstacles(obstacles)
