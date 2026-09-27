extends Node

@export var background_track: MusicTrack;

func _ready() -> void:
	#MusicManager._start_random_track();
	#MusicManager.load_track(background_track);
	#MusicManager.set_stem("base", true);
	pass
