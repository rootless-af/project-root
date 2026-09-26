extends Node2D

signal upgrade_purchased(upgrade_with_cost:UpgradeWithCosts)

enum MineralTypes {ENTIVERA, BARBANIUM, RIHTOCIDE, KVIKTORIUM}

@onready var tool_tip: ToolTip = $ToolTip
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var upgrade_level_label: Label = $UpgradeLevelLabel

@export var disabled := false
@export var upgrade_level:= 1;
@export var tooltip_text: String = ""
@export var main_texture: Texture2D
@export var disabled_texture: Texture2D
@export var insufficient_funds_texture: Texture2D

@export var material_costs: Array[UpgradeWithCosts] = []
@export var unlocked:bool

var inside_area2d:= false
var unlocked_level:= 0
var clickable := false;
var can_unlock := false;
const UPGRADE = preload("uid://cx4b27672a2ps")


func _ready() -> void:
	set_tooltip()
	sprite_2d.texture = main_texture
	tool_tip.set_tooltip_text(tooltip_text)
	if upgrade_level <= 0:
		upgrade_level_label.visible = false
	else:
		update_label()


func _input(event: InputEvent) -> void:
	if clickable:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					handle_press()


func get_materials(level:int) -> UpgradeWithCosts:
	return material_costs.get(level-1)


func set_tooltip():
	if material_costs.size() > 0 and unlocked_level != upgrade_level:
		tool_tip.set_amount(get_materials(unlocked_level + 1).entivera, get_materials(unlocked_level + 1).barbanium, 
			get_materials(unlocked_level + 1).rihtocide, get_materials(unlocked_level + 1).kviktorium)
	else:
		tool_tip.set_amount(0, 0, 0, 0)


func get_upgrade_type(level:int):
	return material_costs.get(level-1).upgrade_type

func handle_press():
	if unlocked_level == upgrade_level:
		unlocked = true
	if unlocked_level < upgrade_level:
		unlocked_level += 1
		set_tooltip()
		upgrade_purchased.emit(get_materials(unlocked_level))
		update_label()


func update_label():
	upgrade_level_label.text = str(unlocked_level) + "/" + str(upgrade_level)


func _on_area_2d_mouse_entered() -> void:
	inside_area2d = true;
	tool_tip.set_tooltip_visible(true)
	if not (disabled or unlocked or not can_unlock):
		clickable = true
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_area_2d_mouse_exited() -> void:
	inside_area2d = false;
	tool_tip.set_tooltip_visible(false)
	clickable = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func check_minerals_amount(minerals:Dictionary):
	if unlocked_level != upgrade_level:
		var can_buy:bool = (
			minerals.get(0) >= get_materials(unlocked_level + 1).entivera
			and minerals.get(1) >= get_materials(unlocked_level + 1).barbanium
			and minerals.get(2) >= get_materials(unlocked_level + 1).rihtocide
			and minerals.get(3) >= get_materials(unlocked_level + 1).kviktorium
		)
		can_unlock = can_buy
		if inside_area2d:
			clickable = can_buy
			print(unlocked_level)
			if not can_buy:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	else:
		if inside_area2d:
			clickable = false
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_skill_tree_mineral_amount_changed(minerals) -> void:
	check_minerals_amount(minerals)
