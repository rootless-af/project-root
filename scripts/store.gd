class_name Store
extends Node2D

# -- References -- 
@onready var handle_area: Area2D = $Handle/Area2D
@onready var buckets: Node2D = $Buckets

# -- Settings --
@export_group("Store Animation")
@export var handle_visible_width: float = 50.0
@export var animation_duration: float = 0.35;

@export_subgroup("Animation")
@export var transition: Tween.TransitionType = Tween.TRANS_QUAD;
@export var ease_type: Tween.EaseType = Tween.EASE_OUT;

# -- State --
var is_open: bool = false;
var is_animating: bool = false;
var store_tween: Tween;

# -- DEBUG --
@export_group("DEBUG")
@export var debug_messages: bool = false;

func _ready() -> void:
	position.x = get_closed_x();
	
	handle_area.input_event.connect(_on_handle_input_event);
	
	for child in buckets.get_children():
		if child is Bucket:
			child.store = self;

func get_open_x() -> float:
	return 0.0;

func get_closed_x() -> float:
	var viewport_width := get_viewport_rect().size.x;
	return viewport_width - handle_visible_width;

func _on_handle_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if debug_messages:
				print("[Store] Clicked on the handle!")
			toggle_store();

func toggle_store() -> void:
	if debug_messages:
				print("[Store] Toggle from: ", is_open, " to ", !is_open);
	if is_open:
		close_store();
	else:
		open_store();

func open_store() -> void:
	if is_animating:
		return;
	
	is_open = true;
	_slide_to(get_open_x());

func close_store() -> void:
	if is_animating:
		return;
	
	is_open = false;
	_slide_to(get_closed_x());

func _slide_to(target_x: float) -> void:
	if store_tween:
		store_tween.kill();
	
	is_animating = true;
	
	store_tween = create_tween();
	store_tween.set_trans(transition);
	store_tween.set_ease(ease_type);
	
	store_tween.tween_property(
		self,
		"position:x",
		target_x,
		animation_duration
	);
	
	store_tween.finished.connect(_on_slide_finished);

func _on_slide_finished() -> void:
	is_animating = false;
