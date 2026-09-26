class_name ToolTip
extends CanvasLayer

@onready var label: Label = $Label

@export var text:String = "Sample" 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = text
	label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if label.visible:
		label.position = get_viewport().get_mouse_position() + Vector2(20, 20)

func set_tooltip_visible(is_visible):
	label.visible = is_visible
