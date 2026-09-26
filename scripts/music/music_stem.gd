class_name MusicStem
extends Resource

@export var id: StringName;
@export var audio: AudioStream;
@export var volume_db: float = 0.0;
@export var fade_in_beats: float = 2.0;
@export var fade_out_beats: float = 2.0;
@export var loop: bool = true;
