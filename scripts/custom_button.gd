extends Node2D

@export var disabled := true
@onready var tool_tip: ToolTip = $ToolTip
var clickable := false;


func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if clickable:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					print("clicked")

func _on_area_2d_mouse_entered() -> void:
	tool_tip.set_tooltip_visible(true)
	if not disabled:
		clickable = true
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_area_2d_mouse_exited() -> void:
	tool_tip.set_tooltip_visible(false)
	clickable = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
