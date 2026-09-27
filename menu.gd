extends CanvasLayer

@export var audio_bus_name := "Master"

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)
@onready var volume_slider: HSlider = $VolumeSlider


func _ready() -> void:
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_bus))


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))


func toggle_menu() -> void:
	visible = !visible


func restart() -> void:
	get_tree().reload_current_scene()
