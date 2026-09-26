extends Node2D


@onready var branch_ability: CheckButton = $BranchAbility
@onready var branch_chance: CheckButton = $BranchChance
@onready var branch_chance_2: CheckButton = $BranchChance2
@onready var branch_tips: CheckButton = $BranchTips
@onready var branch_tips_2: CheckButton = $BranchTips2
@onready var angle: CheckButton = $Angle
@onready var angle_2: CheckButton = $Angle2
@onready var straighten: CheckButton = $Straighten
@onready var straighten_2: CheckButton = $Straighten2
@onready var width: CheckButton = $Width
@onready var growth_depth: CheckButton = $GrowthDepth
@onready var growth_depth_2: CheckButton = $GrowthDepth2
@onready var growth_depth_3: CheckButton = $GrowthDepth3

const ROOT = preload("uid://d1pn0awo34ut7")
var root_instance = null;
var root = null;

const UPGRADE = preload("uid://cx4b27672a2ps")
const ANGLE_UPGRADE = preload("uid://df6dfebnjccbh")
const BRANCH_CHANCE_UPGRADE = preload("uid://mharjf5qjxw8")
const BRANCH_TIPS_UPGRADE = preload("uid://c1dd5r1p82meg")
const DEPTH_UPGRADE = preload("uid://dxuhkvs3nfnv8")
const STRAIGHTEN_UPGRADE = preload("uid://cukw5ijc63gis")
const WIDTH_UPGRADE = preload("uid://oyi56l1p0qru")

func _ready() -> void:
	branch_ability.disabled = false
	branch_chance.disabled = true
	branch_chance_2.disabled = true
	branch_tips.disabled = true
	branch_tips_2.disabled = true
	angle.disabled = false
	angle_2.disabled = true
	straighten.disabled = false
	straighten_2.disabled = true
	width.disabled = true
	growth_depth.disabled = true
	growth_depth_2.disabled = true
	growth_depth_3.disabled = true
	root_instance = ROOT.instantiate()
	root_instance.max_active_tips = 1


func apply_upgrade(upgrade_type:Resource):
	var upgrade:Upgrade = UPGRADE.instantiate()
	upgrade.upgrade_base = upgrade_type
	test_upgrade(upgrade)


func test_upgrade(upgrade:Upgrade):
	root_instance.add_child(upgrade)


func _on_branch_ability_toggled(toggled_on: bool) -> void:
	branch_ability.disabled = true
	growth_depth.disabled = false
	branch_chance.disabled = false
	branch_tips.disabled = false
	apply_upgrade(BRANCH_TIPS_UPGRADE)
	apply_upgrade(BRANCH_CHANCE_UPGRADE)


func _on_branch_chance_toggled(toggled_on: bool) -> void:
	branch_chance.disabled = true
	branch_chance_2.disabled = false
	apply_upgrade(BRANCH_CHANCE_UPGRADE)


func _on_branch_chance_2_toggled(toggled_on: bool) -> void:
	branch_chance_2.disabled = true
	apply_upgrade(BRANCH_CHANCE_UPGRADE)


func _on_branch_tips_toggled(toggled_on: bool) -> void:
	branch_tips.disabled = true
	branch_tips_2.disabled = false
	apply_upgrade(BRANCH_TIPS_UPGRADE)


func _on_branch_tips_2_toggled(toggled_on: bool) -> void:
	branch_tips_2.disabled = true
	apply_upgrade(BRANCH_TIPS_UPGRADE)


func _on_angle_toggled(toggled_on: bool) -> void:
	angle.disabled = true
	straighten.disabled = true
	angle_2.disabled = false
	apply_upgrade(ANGLE_UPGRADE)


func _on_angle_2_toggled(toggled_on: bool) -> void:
	angle_2.disabled = true
	width.disabled = false
	apply_upgrade(ANGLE_UPGRADE)


func _on_straighten_toggled(toggled_on: bool) -> void:
	angle.disabled = true
	straighten.disabled = true
	straighten_2.disabled = false
	apply_upgrade(STRAIGHTEN_UPGRADE)


func _on_straighten_2_toggled(toggled_on: bool) -> void:
	straighten_2.disabled = true
	width.disabled = false
	apply_upgrade(STRAIGHTEN_UPGRADE)


func _on_width_toggled(toggled_on: bool) -> void:
	width.disabled = true
	apply_upgrade(WIDTH_UPGRADE)


func _on_growth_depth_toggled(toggled_on: bool) -> void:
	growth_depth.disabled = true
	growth_depth_2.disabled = false
	apply_upgrade(DEPTH_UPGRADE)


func _on_growth_depth_2_toggled(toggled_on: bool) -> void:
	growth_depth_2.disabled = true
	growth_depth_3.disabled = false
	apply_upgrade(DEPTH_UPGRADE)


func _on_growth_depth_3_toggled(toggled_on: bool) -> void:
	growth_depth_3.disabled = true
	apply_upgrade(DEPTH_UPGRADE)


func _on_test_start_button_pressed() -> void:
	if root == null:
		root = root_instance.duplicate()
		root.position += Vector2(500, 0)
		print(root)
		get_parent().add_child(root)


func _on_test_stop_button_pressed() -> void:
	if root != null:
		root.queue_free()
		root = null;
