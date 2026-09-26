extends Node

@export var background_track: MusicTrack;

func _ready() -> void:
	MusicManager.load_track(background_track);
	MusicManager.set_stem("base", true);
