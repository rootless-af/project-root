class_name SkillTreeButton
extends Node2D

signal upgrade_purchased(upgrade_with_cost: UpgradeWithCosts)
signal upgrade_completed
signal upgrade_started

@onready var tool_tip: ToolTip = $ToolTip
@onready var sprite: Sprite2D = $Sprite2D
@onready var upgrade_level_label: Label = $UpgradeLevelLabel

@export var disabled := false
@export var upgrade_level := 1
@export var tooltip_text: String = ""

@export var can_upgrade_hover_texture: Texture2D
@export var can_upgrade_texture: Texture2D
@export var disabled_texture: Texture2D
@export var insufficient_funds_texture: Texture2D

@export var material_costs: Array[UpgradeWithCosts] = []
@export var unlocked: bool

var inside_area2d := false
var unlocked_level := 0
var clickable := false
var can_unlock := false

const UPGRADE = preload("uid://cx4b27672a2ps")


func _ready() -> void:
	if unlocked:
		unlocked_level = upgrade_level

	set_tooltip()
	tool_tip.set_tooltip_text(tooltip_text)

	if upgrade_level <= 0:
		upgrade_level_label.visible = false
	else:
		update_label()

	# Check whether the initial upgrade is free.
	check_if_free()

	update_visual_state()


func _input(event: InputEvent) -> void:
	if not clickable:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			handle_press()


func get_materials(level: int) -> UpgradeWithCosts:
	return material_costs.get(level - 1)


func set_tooltip() -> void:
	if material_costs.size() > 0 and unlocked_level != upgrade_level:
		var cost := get_materials(unlocked_level + 1)

		tool_tip.set_amount(
			cost.entivera,
			cost.barbanium,
			cost.rihtocide,
			cost.kviktorium
		)
	else:
		tool_tip.set_amount(0, 0, 0, 0)


func get_upgrade_type(level: int):
	return material_costs.get(level - 1).upgrade_type


func handle_press() -> void:
	if disabled or unlocked or not can_unlock:
		return
	var was_unlocked := unlocked_level > 0
	unlocked_level += 1
	if not was_unlocked:
		upgrade_started.emit()
	set_tooltip()
	upgrade_purchased.emit(get_materials(unlocked_level))
	update_label()

	if unlocked_level >= upgrade_level:
		unlocked = true
		upgrade_completed.emit()
	update_visual_state()


func update_label() -> void:
	upgrade_level_label.text = str(unlocked_level) + "/" + str(upgrade_level)


func disable(value: bool) -> void:
	disabled = value
	update_visual_state()


func update_visual_state() -> void:
	clickable = false

	# Disabled always takes priority.
	if disabled:
		sprite.texture = disabled_texture
		set_cursor(false)
		return

	# Already fully upgraded.
	if unlocked or unlocked_level >= upgrade_level:
		sprite.texture = can_upgrade_texture
		set_cursor(false)
		return

	# Can't currently afford it.
	if not can_unlock:
		sprite.texture = insufficient_funds_texture
		set_cursor(false)
		return

	# Can purchase.
	clickable = inside_area2d

	if inside_area2d:
		sprite.texture = can_upgrade_hover_texture
		set_cursor(true)
	else:
		sprite.texture = can_upgrade_texture
		set_cursor(false)


func set_cursor(pointing_hand: bool) -> void:
	if pointing_hand:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_area_2d_mouse_entered() -> void:
	inside_area2d = true
	tool_tip.set_tooltip_visible(true)

	update_visual_state()


func _on_area_2d_mouse_exited() -> void:
	inside_area2d = false
	tool_tip.set_tooltip_visible(false)

	update_visual_state()


func check_if_free() -> void:
	if unlocked_level >= upgrade_level:
		can_unlock = false
		return

	if material_costs.is_empty():
		can_unlock = true
		return

	var cost := get_materials(unlocked_level + 1)

	can_unlock = (
		cost.entivera == 0
		and cost.barbanium == 0
		and cost.rihtocide == 0
		and cost.kviktorium == 0
	)


func check_minerals_amount(minerals: Dictionary) -> void:
	if unlocked_level >= upgrade_level:
		can_unlock = false
		update_visual_state()
		return

	# A zero-cost upgrade is always purchasable.
	if material_costs.is_empty():
		can_unlock = true
		update_visual_state()
		return

	var cost := get_materials(unlocked_level + 1)

	# Free upgrade.
	if (
		cost.entivera == 0
		and cost.barbanium == 0
		and cost.rihtocide == 0
		and cost.kviktorium == 0
	):
		can_unlock = true
		update_visual_state()
		return

	# Normal upgrade with a cost.
	can_unlock = (
		minerals.get(0, 0) >= cost.entivera
		and minerals.get(1, 0) >= cost.barbanium
		and minerals.get(2, 0) >= cost.rihtocide
		and minerals.get(3, 0) >= cost.kviktorium
	)

	update_visual_state()


func _on_skill_tree_mineral_amount_changed(minerals) -> void:
	check_minerals_amount(minerals)
