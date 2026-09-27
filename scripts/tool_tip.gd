class_name ToolTip
extends CanvasLayer

@export var text:String = "Sample" 

@onready var entivera_container: HBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer/EntiveraContainer
@onready var barbanium_container: HBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer/BarbaniumContainer
@onready var rihtocide_container: HBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer/RihtocideContainer
@onready var kviktorium_container: HBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer/KviktoriumContainer
@onready var kviktorium_amount_label: Label = $PanelContainer/VBoxContainer/VBoxContainer/KviktoriumContainer/Label
@onready var entivera_amount_label: Label = $PanelContainer/VBoxContainer/VBoxContainer/EntiveraContainer/Label
@onready var barbanium_amount_label: Label = $PanelContainer/VBoxContainer/VBoxContainer/BarbaniumContainer/Label
@onready var rihtocide_amount_label: Label = $PanelContainer/VBoxContainer/VBoxContainer/RihtocideContainer/Label
@onready var upgrade_text: Label = $PanelContainer/VBoxContainer/UpgradeText
@onready var panel_container: PanelContainer = $PanelContainer
@onready var h_separator: HSeparator = $PanelContainer/VBoxContainer/HSeparator
@onready var v_box_container: VBoxContainer = $PanelContainer/VBoxContainer/VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrade_text.text = text
	self.visible = false
	panel_container.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if panel_container.visible:
		panel_container.position = get_viewport().get_mouse_position() + Vector2(30, 20)

func set_tooltip_visible(is_visible):
	self.visible = is_visible
	panel_container.visible = is_visible


func set_tooltip_text(string):
	upgrade_text.text = string


func set_amount(
	entivera: int,
	barbanium: int,
	rihtocide: int,
	kviktorium: int
) -> void:
	set_label(entivera, entivera_amount_label, entivera_container)
	set_label(barbanium, barbanium_amount_label, barbanium_container)
	set_label(rihtocide, rihtocide_amount_label, rihtocide_container)
	set_label(kviktorium, kviktorium_amount_label, kviktorium_container)
	var has_cost := (
		entivera > 0
		or barbanium > 0
		or rihtocide > 0
		or kviktorium > 0
	)
	h_separator.visible = has_cost
	v_box_container.visible = has_cost
	panel_container.size = Vector2(150, 0)

func set_label(amount: int, label: Label, container: HBoxContainer) -> void:
	container.visible = amount > 0
	label.text = str(amount)
